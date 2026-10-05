import SwiftUI
import AVFoundation

/// Audio player (BEP-0004). Owns an `AVPlayer` and reports playback state back to JS
/// through the author's `set*` / `on*` callbacks. Draws nothing unless `controls` is set,
/// in which case it draws a native-styled control bar.
public struct AudioPlayerComponent: Component {
    public static var directiveName: String = "AudioPlayer"

    @EnvironmentObject private var context: BindJSContext
    @StateObject private var controller = AudioPlayerController()

    public var url: URL?
    public var isPlaying: Bool
    public var currentTime: Double?
    public var rate: Double
    public var volume: Double
    public var isMuted: Bool
    public var loop: Bool
    public var controls: Bool
    public var callbacks: AudioPlayerCallbacks
}

/// Handler ids for the callbacks an `AudioPlayer` reports through.
public struct AudioPlayerCallbacks: Equatable {
    public var setIsPlayingId: String?
    public var setCurrentTimeId: String?
    public var onStatusChangeId: String?
    public var onEndedId: String?
    public var environmentId: String?
}

extension AudioPlayerComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        if let directURL: URL = directive["url"] {
            url = directURL
        } else if let dict: [String: Any] = directive["audio"],
                  let urlString = dict["url"] as? String {
            url = URL(string: urlString)
        } else if let audioURL: URL = directive["audio"] {
            url = audioURL
        } else {
            url = nil
        }

        isPlaying   = directive["isPlaying"] ?? false
        currentTime = directive["currentTime"]
        rate        = directive["rate"] ?? 1
        volume      = directive["volume"] ?? 1
        isMuted     = directive["isMuted"] ?? false
        loop        = directive["loop"] ?? false
        controls    = directive["controls"] ?? false
        callbacks = AudioPlayerCallbacks(
            setIsPlayingId: directive["setIsPlayingId"],
            setCurrentTimeId: directive["setCurrentTimeId"],
            onStatusChangeId: directive["onStatusChangeId"],
            onEndedId: directive["onEndedId"],
            environmentId: directive["environmentId"]
        )
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitAudioPlayer(self)
    }

    fileprivate var configuration: AudioPlayerController.Configuration {
        .init(url: url, isPlaying: isPlaying, currentTime: currentTime, rate: rate,
              volume: volume, isMuted: isMuted, loop: loop, callbacks: callbacks)
    }
}

extension AudioPlayerComponent: View {
    public var body: some View {
        Group {
            if controls {
                AudioControlsBar(controller: controller)
            } else {
                Color.clear
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            }
        }
        .onChange(of: configuration, initial: true) { _, configuration in
            controller.apply(configuration, context: context)
        }
        .onDisappear {
            controller.stop()
        }
    }
}

// MARK: - Controller

@MainActor
final class AudioPlayerController: ObservableObject {
    struct Configuration: Equatable {
        var url: URL?
        var isPlaying: Bool
        var currentTime: Double?
        var rate: Double
        var volume: Double
        var isMuted: Bool
        var loop: Bool
        var callbacks: AudioPlayerCallbacks
    }

    enum Status: String { case loading, ready, buffering, ended, failed }

    /// How often the position is reported while playing (spec: every 0.25 to 0.5 s).
    private static let timeReportInterval = CMTime(seconds: 0.25, preferredTimescale: 600)

    private let player = AVPlayer()
    private weak var context: BindJSContext?
    private var configuration: Configuration?

    private var timeObserver: Any?
    private var playerObservation: NSKeyValueObservation?
    private var itemObservations: [NSKeyValueObservation] = []
    private var endObserver: NSObjectProtocol?

    // State the drawn controls show.
    @Published private(set) var displayTime: Double = 0
    @Published private(set) var duration: Double?
    @Published private(set) var isPlayingNow = false
    @Published private(set) var status: Status = .loading

    /// The last position reported to JS. `currentTime` coming back as that value is the
    /// report echoing through the author's state, not a request to seek.
    private var lastReportedTime: Double?
    private var pendingSeek: Double?
    private var lastStatus: (status: Status, duration: Double?, bufferedTime: Double)?
    private var hasEnded = false
    /// Whether the author's state was last told playback is on: its `isPlaying` when that
    /// changes, or the value most recently sent through `setIsPlaying`.
    private var authorIsPlaying = false
    /// Bumped per seek, so only the latest seek's completion counts.
    private var seekGeneration = 0
    private var isSeeking = false

    init() {
        player.actionAtItemEnd = .pause
        timeObserver = player.addPeriodicTimeObserver(forInterval: Self.timeReportInterval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                // While a seek is in flight the position is still the old one; skip it.
                guard let self, self.player.timeControlStatus == .playing, !self.isSeeking else { return }
                self.displayTime = time.seconds
                self.reportTime(time.seconds)
            }
        }
        playerObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.timeControlStatusChanged() }
        }
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        player.pause()
    }

    func apply(_ new: Configuration, context: BindJSContext) {
        self.context = context
        let old = configuration
        configuration = new

        if old == nil || old?.url != new.url {
            load(new.url, isFirst: old == nil, initialTime: new.currentTime)
        } else if let time = new.currentTime, time != old?.currentTime, time != lastReportedTime {
            seek(to: time)
        }

        player.volume = Float(min(max(new.volume, 0), 1))
        player.isMuted = new.isMuted
        player.defaultRate = Float(new.rate)
        if player.rate != 0 { player.rate = Float(new.rate) }

        // isPlaying is applied when it changes (or the source does), so the drawn
        // controls and media keys can play and pause without the author's state.
        if old == nil || old?.isPlaying != new.isPlaying || old?.url != new.url {
            authorIsPlaying = new.isPlaying
            if new.isPlaying {
                if player.timeControlStatus == .paused { play() }
            } else if player.timeControlStatus != .paused {
                player.pause()
            }
        }
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        configuration = nil
    }

    // MARK: Loading

    private func load(_ url: URL?, isFirst: Bool, initialTime: Double?) {
        itemObservations.removeAll()
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
        lastStatus = nil
        hasEnded = false
        displayTime = 0
        duration = nil
        pendingSeek = isFirst ? initialTime : nil
        isSeeking = false

        guard let url else {
            player.replaceCurrentItem(with: nil)
            return
        }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        reportStatus(.loading)
        if !isFirst { reportTime(0) }

        itemObservations.append(item.observe(\.status, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.itemStatusChanged() }
        })
        itemObservations.append(item.observe(\.loadedTimeRanges, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.reportStatus(self?.lastStatus?.status ?? .loading) }
        })
        itemObservations.append(item.observe(\.duration, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.reportStatus(self?.lastStatus?.status ?? .loading) }
        })
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.didPlayToEnd() }
        }
    }

    // MARK: Drawn controls

    /// Play or pause from the drawn controls. The change reaches the author's state
    /// through `setIsPlaying`, like any playback the author did not request.
    func togglePlaybackFromControls() {
        if player.timeControlStatus == .paused { play() } else { player.pause() }
    }

    /// Seek from the drawn controls; the landing position is reported through `setCurrentTime`.
    func seekFromControls(to time: Double) {
        displayTime = time
        seek(to: time)
    }

    // MARK: Playback

    private func play() {
        guard player.currentItem != nil else { return }
        if hasEnded {
            seek(to: 0)
            reportStatus(.ready)
        }
        player.play()
    }

    private func seek(to time: Double) {
        guard let item = player.currentItem, item.status == .readyToPlay else {
            pendingSeek = time
            return
        }
        hasEnded = false
        seekGeneration += 1
        let generation = seekGeneration
        isSeeking = true
        // A new seek cancels the one in flight, so a scrub never queues up stale seeks.
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, generation == self.seekGeneration else { return }
                self.isSeeking = false
                self.displayTime = self.player.currentTime().seconds
                self.reportTime(self.displayTime)
            }
        }
    }

    private func itemStatusChanged() {
        guard let item = player.currentItem else { return }
        switch item.status {
        case .readyToPlay:
            if let pendingSeek {
                self.pendingSeek = nil
                seek(to: pendingSeek)
            }
            reportStatus(.ready)
        case .failed:
            reportStatus(.failed, error: item.error?.localizedDescription ?? "The audio could not be loaded.")
            reportIsPlaying(false)
        default:
            break
        }
    }

    private func timeControlStatusChanged() {
        isPlayingNow = player.timeControlStatus != .paused
        guard configuration != nil, player.currentItem != nil else { return }
        switch player.timeControlStatus {
        case .waitingToPlayAtSpecifiedRate:
            if lastStatus?.status == .ready { reportStatus(.buffering) }
        case .playing:
            reportStatus(.ready)
            // Started by the drawn controls or a remote command, not the author.
            reportIsPlaying(true)
        case .paused:
            // Stopped by the drawn controls, an interruption, or a route change, not the author.
            // The end of the media is reported by didPlayToEnd instead.
            if !hasEnded && !isAtEnd {
                reportIsPlaying(false)
            }
        @unknown default:
            break
        }
    }

    private var isAtEnd: Bool {
        guard let duration = player.currentItem?.duration.seconds, duration.isFinite else { return false }
        return player.currentTime().seconds >= duration - 0.05
    }

    private func didPlayToEnd() {
        guard let configuration else { return }
        if configuration.loop {
            player.seek(to: .zero)
            player.play()
            return
        }
        hasEnded = true
        displayTime = player.currentTime().seconds
        reportTime(displayTime)
        reportStatus(.ended)
        reportIsPlaying(false)
        call(\.onEndedId, nil)
    }

    // MARK: Reporting

    /// Tells the author's state about playback it did not request, once per change.
    private func reportIsPlaying(_ isPlaying: Bool) {
        guard isPlaying != authorIsPlaying else { return }
        authorIsPlaying = isPlaying
        call(\.setIsPlayingId, isPlaying)
    }

    private func reportTime(_ time: Double) {
        guard time.isFinite else { return }
        lastReportedTime = time
        call(\.setCurrentTimeId, time)
    }

    private func reportStatus(_ status: Status, error: String? = nil) {
        let item = player.currentItem
        let rawDuration = item?.duration.seconds
        let duration: Double? = {
            guard let item, let rawDuration, !rawDuration.isNaN else { return nil }
            return item.duration.isIndefinite ? .infinity : rawDuration
        }()
        let buffered = item?.loadedTimeRanges.last.map { CMTimeRangeGetEnd($0.timeRangeValue).seconds } ?? 0

        self.status = status
        self.duration = duration

        if let last = lastStatus, last.status == status, last.duration == duration,
           buffered - last.bufferedTime < 1, error == nil {
            return
        }
        lastStatus = (status, duration, buffered)

        var info: [String: Any] = [
            "status": status.rawValue,
            "duration": duration.map { $0 as Any } ?? NSNull(),
            "bufferedTime": buffered.isFinite ? buffered : 0,
        ]
        if let error { info["error"] = error }
        call(\.onStatusChangeId, info)
    }

    private func call(_ key: KeyPath<AudioPlayerCallbacks, String?>, _ value: Any?) {
        guard let context, let callbacks = configuration?.callbacks, let id = callbacks[keyPath: key] else { return }
        if let environmentId = callbacks.environmentId {
            context.restoreEnvironment(id: environmentId)
        }
        // A no-argument callback receives an empty array, matching Button's handler.
        _ = context.callEventHandler(id: id, arguments: value ?? [Any]())
    }
}

// MARK: - Drawn controls

/// The control bar drawn for `controls: true`: play/pause, elapsed time, a scrubber, and
/// remaining time, at a fixed 44pt height.
private struct AudioControlsBar: View {
    @ObservedObject var controller: AudioPlayerController
    @State private var scrubTime: Double?

    private var knownDuration: Double? {
        guard let duration = controller.duration, duration.isFinite, duration > 0 else { return nil }
        return duration
    }

    private var position: Double { scrubTime ?? controller.displayTime }

    var body: some View {
        HStack(spacing: 10) {
            playButton
                .frame(width: 28, height: 28)

            Text(Self.format(position))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            scrubber

            Text(knownDuration.map { "-" + Self.format(max($0 - position, 0)) } ?? "--:--")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
    }

    @ViewBuilder
    private var playButton: some View {
        switch controller.status {
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.secondary)
                .accessibilityLabel("Audio unavailable")
        case .buffering:
            ProgressView()
                .controlSize(.small)
        default:
            Button {
                controller.togglePlaybackFromControls()
            } label: {
                Image(systemName: controller.isPlayingNow ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .accessibilityLabel(controller.isPlayingNow ? "Pause" : "Play")
        }
    }

    @ViewBuilder
    private var scrubber: some View {
        let upperBound = knownDuration ?? 1
        #if os(tvOS)
        ProgressView(value: min(position, upperBound), total: upperBound)
        #else
        Slider(
            value: Binding(get: { min(position, upperBound) }, set: { scrubTime = $0 }),
            in: 0...upperBound
        ) { isEditing in
            if isEditing {
                // Pin the thumb as soon as a drag starts, so playback can't move it under the finger.
                scrubTime = position
                return
            }
            guard let scrubTime else { return }
            // The controller holds the thumb at the target and ignores playback updates
            // until the seek lands, so releasing doesn't flick back to the old position.
            controller.seekFromControls(to: scrubTime)
            self.scrubTime = nil
        }
        .disabled(knownDuration == nil)
        .accessibilityLabel("Position")
        #endif
    }

    private static func format(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "--:--" }
        let total = Int(seconds.rounded(.down))
        let (hours, minutes, secs) = (total / 3600, (total % 3600) / 60, total % 60)
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%d:%02d", minutes, secs)
    }
}
