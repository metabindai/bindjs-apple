import Foundation
import CoreText
import SwiftUI
import Combine
import os.log

// MARK: - Logger

extension Logger {
    /// Logger for font loading operations
    static let fontLoading = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FontCustom", category: "FontLoading")
}

// MARK: - FontCustomComponent

public struct FontCustomComponent: Component {
    public static var directiveName: String = "FontCustom"

    public var family: String
    public var size: CGFloat
    public var url: URL?
}

extension FontCustomComponent {
    public init?(from directive: Directive) {
        self.family = directive["family"] ?? "Not Specified"
        self.size = directive["size"] ?? 17.0
        self.url = directive["url"]
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitFontCustom(self)
    }
}

extension FontCustomComponent: ViewModifier {
    public func body(content: Content) -> some View {
        FontLoaderView(url: url, family: family, size: size) {
            content
        }
    }
}

// MARK: - FontLoaderView

/// A helper view that owns the @State for font loading.
/// Using a View (instead of storing @State in the ViewModifier) ensures
/// stable identity across parent re-renders.
private struct FontLoaderView<Content: View>: View {
    let url: URL?
    let family: String
    let size: CGFloat
    let content: Content

    @State private var postScriptName: String?
    @State private var isLoading = false

    init(url: URL?, family: String, size: CGFloat, @ViewBuilder content: () -> Content) {
        self.url = url
        self.family = family
        self.size = size
        self.content = content()
    }

    var body: some View {
        content
            .font(makeFont())
            .id(postScriptName)
            .task(id: url) {
                await loadFontIfNeeded()
            }
            .onReceive(FontLoadedPublisher.shared.publisher) { loadedURL in
                // When any font finishes loading, check if it's ours
                if loadedURL == url, postScriptName == nil {
                    Task {
                        if let name = await FontCache.shared.cachedPostScriptName(for: loadedURL) {
                            postScriptName = name
                        }
                    }
                }
            }
    }

    // MARK: — Helper: choose the Font to apply
    private func makeFont() -> Font {
        let textStyle = nearestTextStyle(for: size)
        if let psName = postScriptName {
            // We have a downloaded font → use it, scaling relative to the nearest text style
            Logger.fontLoading.debug("Using custom font: \(psName, privacy: .public) at size \(size, privacy: .public)")
            return .custom(psName, size: size, relativeTo: textStyle)
        } else if url != nil {
            // We're still loading → use system, scaling relative to the nearest text style
            Logger.fontLoading.debug("Font loading in progress, using system font at size \(size, privacy: .public)")
            return .system(size: size, weight: .regular, design: .default)
        } else {
            // No URL was provided → try using the family name locally, scaling relative to the nearest text style
            Logger.fontLoading.debug("Attempting to use local font family: \(family, privacy: .public)")
            return .custom(family, size: size, relativeTo: textStyle)
        }
    }

    /// Find the closest dynamic TextStyle for a given base size
    private func nearestTextStyle(for size: CGFloat) -> Font.TextStyle {
        // Mapping of base point sizes to SwiftUI TextStyles (iOS default Dynamic Type sizes)
        let styleMap: [(Font.TextStyle, CGFloat)] = [
            (.largeTitle, 34),
            (.title,      28),
            (.title2,     22),
            (.title3,     20),
            (.headline,   17),
            (.body,       17),
            (.callout,    16),
            (.subheadline,15),
            (.footnote,   13),
            (.caption,    12),
            (.caption2,   11)
        ]
        // Pick the style whose base size is closest to our requested size
        let nearest = styleMap.min(by: { abs($0.1 - size) < abs($1.1 - size) })!
        Logger.fontLoading.debug("Mapped size \(size, privacy: .public) to text style: \(String(describing: nearest.0), privacy: .public)")
        return nearest.0
    }

    // MARK: — Async loader
    private func loadFontIfNeeded() async {
        guard
            !isLoading,
            postScriptName == nil,
            let fontURL = url
        else {
            if isLoading {
                Logger.fontLoading.debug("Font load already in progress")
            } else if postScriptName != nil {
                Logger.fontLoading.debug("Font already loaded")
            }
            return
        }

        isLoading = true
        defer { isLoading = false }

        Logger.fontLoading.info("Loading font from URL: \(fontURL, privacy: .private(mask: .hash))")

        do {
            // Ask our FontCache actor
            let name = try await FontCache.shared.postScriptName(for: fontURL)
            postScriptName = name
            Logger.fontLoading.info("Successfully loaded font: \(name, privacy: .public)")
        } catch {
            Logger.fontLoading.error("Failed to load font from \(fontURL, privacy: .private(mask: .hash)): \(error, privacy: .public)")
        }
    }
}

// MARK: - FontLoadedPublisher

/// Publishes when a font finishes loading so all views using that font can update
final class FontLoadedPublisher {
    static let shared = FontLoadedPublisher()
    let publisher = PassthroughSubject<URL, Never>()
}

// MARK: - FontCacheError

public enum FontCacheError: Error {
    case downloadFailed(Error)
    case invalidFontData
    case registrationFailed(CFError)
}

// MARK: - FontCache

public actor FontCache {
    public static let shared = FontCache()
    
    /// In-memory map from source URL → registered PostScript name
    private var loadedFonts: [URL: String] = [:]
    
    /// Directory in Caches/Fonts where we store the raw data
    private let cacheDirectory: URL
    
    init() {
        let base = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
        cacheDirectory = base.appendingPathComponent("Fonts", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )
            Logger.fontLoading.info("Font cache directory created at: \(self.cacheDirectory.path, privacy: .private)")
        } catch {
            Logger.fontLoading.error("Failed to create font cache directory: \(error, privacy: .public)")
        }
    }
    
    /// Downloads (or reads from disk) the font at `url`, registers it once,
    /// and returns its PostScript name.
    public func postScriptName(for url: URL) async throws -> String {
        // 1) Reuse in-memory if already loaded
        if let existing = loadedFonts[url] {
            Logger.fontLoading.debug("Font already in memory cache: \(existing, privacy: .public)")
            return existing
        }
        
        // 2) Compute local file URL in Caches/Fonts
        let localFile = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        Logger.fontLoading.debug("Local cache path: \(localFile.lastPathComponent, privacy: .public)")
        
        // 3) Ensure the parent folder exists
        let parentDir = localFile.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: parentDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // 4) Load font data from disk or download it
        let data: Data
        if FileManager.default.fileExists(atPath: localFile.path) {
            Logger.fontLoading.info("Loading font from cache: \(localFile.lastPathComponent, privacy: .public)")
            data = try Data(contentsOf: localFile)
        } else {
            Logger.fontLoading.info("Downloading font: \(url.lastPathComponent, privacy: .public)")
            do {
                let (downloaded, response) = try await URLSession.shared.data(from: url)
                data = downloaded
                
                if let httpResponse = response as? HTTPURLResponse {
                    Logger.fontLoading.debug("Download completed with status code: \(httpResponse.statusCode, privacy: .public)")
                }
                
                try data.write(to: localFile, options: .atomic)
                Logger.fontLoading.info("Font cached successfully: \(localFile.lastPathComponent, privacy: .public), size: \(data.count) bytes")
            } catch {
                Logger.fontLoading.error("Font download failed: \(error, privacy: .public)")
                throw FontCacheError.downloadFailed(error)
            }
        }
        
        // 5) Wrap in CGFont and register with CoreText
        guard
            let provider = CGDataProvider(data: data as CFData),
            let cgFont   = CGFont(provider)
        else {
            Logger.fontLoading.error("Invalid font data for: \(url.lastPathComponent, privacy: .public)")
            throw FontCacheError.invalidFontData
        }
        
        var registrationError: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &registrationError)
        if let err = registrationError?.takeRetainedValue() {
            Logger.fontLoading.error("Font registration failed: \(err, privacy: .public)")
            throw FontCacheError.registrationFailed(err)
        }
        
        // 6) Extract and cache its PostScript name
        guard let psName = cgFont.postScriptName as String? else {
            Logger.fontLoading.error("Failed to extract PostScript name from font")
            throw FontCacheError.invalidFontData
        }
        
        loadedFonts[url] = psName
        Logger.fontLoading.info("Font registered successfully: \(psName, privacy: .public)")

        // Notify all listeners that this font is now available
        Task { @MainActor in
            FontLoadedPublisher.shared.publisher.send(url)
        }

        return psName
    }

    /// Synchronous lookup for already-loaded fonts
    public func cachedPostScriptName(for url: URL) -> String? {
        loadedFonts[url]
    }
}
