import AVFoundation
import Foundation
import Testing
@testable import BindJS

@Suite("AudioPlayer")
@MainActor
struct AudioPlayerTests {

    // MARK: - Decoding

    @Test func decodesPropsAndHandlerIds() throws {
        let directive = Directive(type: "AudioPlayer", props: [
            "url": "https://example.com/episode.mp3",
            "isPlaying": true,
            "currentTime": 12.5,
            "rate": 1.5,
            "volume": 0.8,
            "isMuted": true,
            "loop": true,
            "setIsPlayingId": "a",
            "setCurrentTimeId": "b",
            "onStatusChangeId": "c",
            "onEndedId": "d",
        ])
        let player = try #require(AudioPlayerComponent(from: directive))

        #expect(player.url == URL(string: "https://example.com/episode.mp3"))
        #expect(player.isPlaying)
        #expect(player.currentTime == 12.5)
        #expect(player.rate == 1.5)
        #expect(player.volume == 0.8)
        #expect(player.isMuted)
        #expect(player.loop)
        #expect(player.callbacks == AudioPlayerCallbacks(
            setIsPlayingId: "a", setCurrentTimeId: "b", onStatusChangeId: "c", onEndedId: "d"))
    }

    @Test func decodesAnAssetSourceAndDefaults() throws {
        let directive = Directive(type: "AudioPlayer", props: ["audio": ["url": "https://example.com/a.mp3"]])
        let player = try #require(AudioPlayerComponent(from: directive))

        #expect(player.url == URL(string: "https://example.com/a.mp3"))
        #expect(player.isPlaying == false)
        #expect(player.currentTime == nil)
        #expect(player.rate == 1)
        #expect(player.volume == 1)
        #expect(player.isMuted == false)
        #expect(player.loop == false)
        #expect(player.controls == false)
    }

    @Test func decodesControls() throws {
        let directive = Directive(type: "AudioPlayer", props: ["url": "https://example.com/a.mp3", "controls": true])
        #expect(try #require(AudioPlayerComponent(from: directive)).controls)
    }

    @Test func isRegisteredWithTheFactoryAndTheRuntime() {
        #expect(makeComponent(Directive(type: "AudioPlayer", props: ["url": "https://example.com/a.mp3"])) is AudioPlayerComponent)
        #expect(BindJSContext().evaluateForTesting("runtime.getComponent('AudioPlayer') !== undefined") == "true")
    }

    // MARK: - Playback

    /// Plays a short generated file to the end and checks what reaches JS, in order.
    @Test func reportsTimeStatusAndEndToJavaScript() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 0.8)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("""
        globalThis.events = [];
        runtime.storedFunctions['playing'] = (v) => events.push(['playing', v]);
        runtime.storedFunctions['time'] = (t) => events.push(['time', t]);
        runtime.storedFunctions['status'] = (s) => events.push(['status', s.status, s.duration]);
        runtime.storedFunctions['ended'] = () => events.push(['ended']);
        """)

        let controller = AudioPlayerController()
        var configuration = AudioPlayerController.Configuration(
            url: url, isPlaying: false, currentTime: 0, rate: 1, volume: 1, isMuted: true, loop: false,
            callbacks: AudioPlayerCallbacks(setIsPlayingId: "playing", setCurrentTimeId: "time",
                                            onStatusChangeId: "status", onEndedId: "ended"))
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("events.some(e => e[1] === 'ready')") == "true" }

        configuration.isPlaying = true
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("events.some(e => e[0] === 'ended')") == "true" }

        let events = try #require(context.evaluateForTesting("JSON.stringify(events)"))
        let decoded = try #require(try JSONSerialization.jsonObject(with: Data(events.utf8)) as? [[Any]])
        let names = decoded.map { "\($0[0])" + ($0.count > 1 && $0[0] as? String == "status" ? ":\($0[1])" : "") }

        #expect(names.first == "status:loading")
        #expect(names.contains("status:ready"))
        // Ended order: final time, status ended, setIsPlaying(false), onEnded.
        let tail = Array(names.suffix(4))
        #expect(tail == ["time", "status:ended", "playing", "ended"])
        #expect(decoded.last(where: { $0[0] as? String == "playing" })?[1] as? Bool == false)
        let duration = decoded.last(where: { $0[0] as? String == "status" })?[2] as? Double
        #expect(abs((duration ?? 0) - 0.8) < 0.05)
    }

    @Test func ignoresTheEchoOfItsLastReport() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 4)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("""
        globalThis.times = [];
        globalThis.statuses = [];
        runtime.storedFunctions['time'] = (t) => times.push(t);
        runtime.storedFunctions['status'] = (s) => statuses.push(s.status);
        """)

        let controller = AudioPlayerController()
        var configuration = AudioPlayerController.Configuration(
            url: url, isPlaying: false, currentTime: nil, rate: 1, volume: 1, isMuted: true, loop: false,
            callbacks: AudioPlayerCallbacks(setCurrentTimeId: "time", onStatusChangeId: "status"))
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("statuses.includes('ready')") == "true" }

        // A new value seeks, and the player reports where it landed.
        configuration.currentTime = 2.5
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("times.length") == "1" }
        #expect(context.evaluateForTesting("times[0]") == "2.5")

        // Echoing that report back does not seek again.
        configuration.currentTime = 2.5
        controller.apply(configuration, context: context)
        try await Task.sleep(for: .milliseconds(300))
        #expect(context.evaluateForTesting("times.length") == "1")
    }

    /// The drawn controls play and pause without the author's state, and report each change.
    @Test func drawnControlsReportPlaybackTheAuthorDidNotRequest() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 4)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("""
        globalThis.playing = [];
        globalThis.statuses = [];
        runtime.storedFunctions['playing'] = (v) => playing.push(v);
        runtime.storedFunctions['status'] = (s) => statuses.push(s.status);
        """)

        let controller = AudioPlayerController()
        let configuration = AudioPlayerController.Configuration(
            url: url, isPlaying: false, currentTime: nil, rate: 1, volume: 1, isMuted: true, loop: false,
            callbacks: AudioPlayerCallbacks(setIsPlayingId: "playing", onStatusChangeId: "status"))
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("statuses.includes('ready')") == "true" }
        #expect(controller.duration.map { abs($0 - 4) < 0.05 } == true)

        controller.togglePlaybackFromControls()
        try await Self.waitUntil { context.evaluateForTesting("playing.join()") == "true" }
        #expect(controller.isPlayingNow)

        // Re-applying the unchanged configuration (the author's state is stale) must not pause.
        controller.apply(configuration, context: context)
        try await Task.sleep(for: .milliseconds(100))
        #expect(controller.isPlayingNow)

        controller.togglePlaybackFromControls()
        try await Self.waitUntil { context.evaluateForTesting("playing.join()") == "true,false" }
        #expect(controller.isPlayingNow == false)
    }

    /// Releasing the drawn scrubber seeks; until the seek lands, the bar keeps showing the
    /// target instead of flicking back to the old playback position.
    @Test func drawnScrubberHoldsTheTargetUntilTheSeekLands() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 6)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("globalThis.statuses = []; runtime.storedFunctions['status'] = (s) => statuses.push(s.status);")
        let controller = AudioPlayerController()
        controller.apply(.init(url: url, isPlaying: true, currentTime: nil, rate: 1, volume: 1, isMuted: true, loop: false,
                               callbacks: AudioPlayerCallbacks(onStatusChangeId: "status")), context: context)
        try await Self.waitUntil { controller.isPlayingNow && controller.displayTime > 0.3 }

        controller.seekFromControls(to: 4)
        var samples: [Double] = []
        for _ in 0..<30 {
            samples.append(controller.displayTime)
            try await Task.sleep(for: .milliseconds(20))
        }

        #expect(samples.allSatisfy { $0 >= 4 - 0.01 }, "display flicked back during the seek: \(samples)")
        #expect(controller.isPlayingNow)
    }

    /// Paused, Go30 → Go40 → Go30: the second Go30 must seek even though 30 was reported before.
    @Test func seeksBackToAValueItReportedEarlier() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 50)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("""
        globalThis.times = []; globalThis.statuses = [];
        runtime.storedFunctions['time'] = (t) => times.push(t);
        runtime.storedFunctions['status'] = (s) => statuses.push(s.status);
        """)
        let controller = AudioPlayerController()
        var configuration = AudioPlayerController.Configuration(
            url: url, isPlaying: false, currentTime: nil, rate: 1, volume: 1, isMuted: true, loop: false,
            callbacks: AudioPlayerCallbacks(setCurrentTimeId: "time", onStatusChangeId: "status"))
        controller.apply(configuration, context: context)
        try await Self.waitUntil { context.evaluateForTesting("statuses.includes('ready')") == "true" }

        for (index, target) in [30.0, 40.0, 30.0].enumerated() {
            configuration.currentTime = target
            controller.apply(configuration, context: context)
            try await Self.waitUntil { context.evaluateForTesting("times.length") == "\(index + 1)" }
            #expect(context.evaluateForTesting("times[\(index)]") == "\(Int(target))", "seek \(index) did not land on \(target)")
            #expect(abs(controller.displayTime - target) < 0.01)
        }
    }

    /// Playing, then a "restart" setting currentTime to 0 seeks, even though 0 was the starting position.
    @Test func restartToZeroWhilePlayingSeeks() async throws {
        let url = try Self.makeSilentAudioFile(seconds: 6)
        defer { try? FileManager.default.removeItem(at: url) }

        let context = BindJSContext()
        _ = context.evaluateForTesting("""
        globalThis.times = [];
        runtime.storedFunctions['time'] = (t) => times.push(t);
        """)
        let controller = AudioPlayerController()
        var configuration = AudioPlayerController.Configuration(
            url: url, isPlaying: true, currentTime: 0, rate: 1, volume: 1, isMuted: true, loop: false,
            callbacks: AudioPlayerCallbacks(setCurrentTimeId: "time"))
        controller.apply(configuration, context: context)
        try await Self.waitUntil { controller.displayTime > 0.5 }

        // The author's state has followed the reports; now it asks for 0 again.
        configuration.currentTime = Double(context.evaluateForTesting("times[times.length - 1]") ?? "") ?? 1
        controller.apply(configuration, context: context)
        configuration.currentTime = 0
        controller.apply(configuration, context: context)

        try await Self.waitUntil { controller.displayTime < 0.4 }
        #expect(controller.isPlayingNow)
    }

    // MARK: - Helpers

    private static func makeSilentAudioFile(seconds: Double) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audioplayer-\(UUID()).caf")
        let format = try #require(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1))
        let frames = AVAudioFrameCount(seconds * format.sampleRate)
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
        return url
    }

    /// Playback runs in real time and CI runners are slow to start it, so the default is generous.
    private static func waitUntil(
        timeout: Double = 10,
        sourceLocation: SourceLocation = #_sourceLocation,
        _ condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            guard Date() < deadline else {
                Issue.record("Timed out after \(timeout)s waiting for condition", sourceLocation: sourceLocation)
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}
