import Foundation
import CoreText
import SwiftUI
import os.log

// MARK: - Logger

extension Logger {
    /// Logger for font loading operations
    static let fontLoading = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FontCustom", category: "FontLoading")
}

// MARK: - FontCustomComponent

public struct FontCustomComponent: Component {
    public static var directiveName: String = "FontCustom"
    
    // MARK: — Properties
    public var family: String
    public var size: CGFloat
    public var url: URL?
    
    // MARK: — State
    @State private var postScriptName: String?
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
        content
            .font(makeFont())
            .task(id: url) {
                await loadFontIfNeeded()
            }
    }
    
    // MARK: — Helper: choose the Font to apply
    private func makeFont() -> Font {
        let textStyle = nearestTextStyle(for: size)
        if let psName = postScriptName {
            // We have a cached font → use it immediately
            Logger.fontLoading.debug("Using custom font: \(psName, privacy: .public) at size \(self.size, privacy: .public)")
            return .custom(psName, size: size, relativeTo: textStyle)
        } else if url != nil {
            // Font not in cache yet → use system font
            Logger.fontLoading.debug("Font not in cache, using system font at size \(self.size, privacy: .public)")
            return .system(size: size, weight: .regular, design: .default)
        } else {
            // No URL was provided → try using the family name locally
            Logger.fontLoading.debug("Attempting to use local font family: \(self.family, privacy: .public)")
            return .custom(family, size: size, relativeTo: textStyle)
        }
    }
    
    /// Find the closest dynamic TextStyle for a given base size
    private func nearestTextStyle(for size: CGFloat) -> Font.TextStyle {
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
        let nearest = styleMap.min(by: { abs($0.1 - size) < abs($1.1 - size) })!
        Logger.fontLoading.debug("Mapped size \(size, privacy: .public) to text style: \(String(describing: nearest.0), privacy: .public)")
        return nearest.0
    }
    
    // MARK: — Async loader
    private func loadFontIfNeeded() async {
        guard let fontURL = url else { return }
        
        // First check cache to potentially update our state
        if postScriptName == nil {
            postScriptName = await FontCache.shared.getCachedPostScriptName(for: fontURL)
        }
        
        // Skip full load if already in cache
        if postScriptName != nil {
            Logger.fontLoading.debug("Font already loaded")
            return
        }
        
        Logger.fontLoading.info("Loading font from URL: \(fontURL, privacy: .private(mask: .hash))")
        
        do {
            let psName = try await FontCache.shared.loadFont(from: fontURL)
            postScriptName = psName
            Logger.fontLoading.info("Successfully loaded font: \(psName, privacy: .public)")
        } catch {
            Logger.fontLoading.error("Failed to load font from \(fontURL, privacy: .private(mask: .hash)): \(error, privacy: .public)")
        }
    }
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
    
    /// Track ongoing downloads to prevent duplicate requests
    private var loadingTasks: [URL: Task<String, Error>] = [:]
    
    /// Directory in Caches/Fonts where we store the raw data
    private let cacheDirectory: URL
    
    private init() {
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
            
            // Pre-load all cached fonts on initialization
            Task {
                await preloadCachedFonts()
            }
        } catch {
            Logger.fontLoading.error("Failed to create font cache directory: \(error, privacy: .public)")
        }
    }
    
    /// Pre-loads all fonts from the cache directory
    private func preloadCachedFonts() async {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil
            )
            
            for fileURL in contents {
                guard fileURL.pathExtension == "ttf" || fileURL.pathExtension == "otf" else { continue }
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    if let psName = await registerFontData(data) {
                        // Create a synthetic URL based on the filename for cache lookup
                        // This assumes your URLs end with the same filename as cached
                        loadedFonts[fileURL] = psName
                        Logger.fontLoading.info("Pre-loaded cached font: \(fileURL.lastPathComponent, privacy: .public) -> \(psName, privacy: .public)")
                    }
                } catch {
                    Logger.fontLoading.error("Failed to pre-load font \(fileURL.lastPathComponent, privacy: .public): \(error, privacy: .public)")
                }
            }
        } catch {
            Logger.fontLoading.error("Failed to enumerate cache directory: \(error, privacy: .public)")
        }
    }
    
    /// Check if a font is already cached (async version for use from views)
    public func getCachedPostScriptName(for url: URL) async -> String? {
        // First check in-memory cache
        if let psName = loadedFonts[url] {
            return psName
        }
        
        // Check if file exists on disk and load it
        let localFile = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        guard FileManager.default.fileExists(atPath: localFile.path) else {
            return nil
        }
        
        // Try to load and register the font
        do {
            let data = try Data(contentsOf: localFile)
            if let psName = await registerFontData(data) {
                loadedFonts[url] = psName
                Logger.fontLoading.info("Loaded cached font: \(url.lastPathComponent, privacy: .public) -> \(psName, privacy: .public)")
                return psName
            }
        } catch {
            Logger.fontLoading.error("Failed to load cached font: \(error, privacy: .public)")
        }
        
        return nil
    }
    
    /// Downloads (or reads from disk) the font at `url`, registers it once,
    /// and returns its PostScript name.
    public func loadFont(from url: URL) async throws -> String {
        // 1) Return immediately if already loaded
        if let existing = loadedFonts[url] {
            Logger.fontLoading.debug("Font already in memory cache: \(existing, privacy: .public)")
            return existing
        }
        
        // 2) Check if we're already loading this font
        if let existingTask = loadingTasks[url] {
            Logger.fontLoading.debug("Font load already in progress, waiting...")
            return try await existingTask.value
        }
        
        // 3) Create a new loading task
        let task = Task<String, Error> {
            defer { loadingTasks[url] = nil }
            
            let localFile = cacheDirectory.appendingPathComponent(url.lastPathComponent)
            Logger.fontLoading.debug("Local cache path: \(localFile.lastPathComponent, privacy: .public)")
            
            // Ensure the parent folder exists
            try FileManager.default.createDirectory(
                at: localFile.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            // Load font data from disk or download it
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
            
            // Register the font
            guard let psName = await self.registerFontData(data) else {
                throw FontCacheError.invalidFontData
            }
            
            self.updateCache(url: url, psName: psName)
            Logger.fontLoading.info("Font registered successfully: \(psName, privacy: .public)")
            return psName
        }
        
        loadingTasks[url] = task
        return try await task.value
    }
    
    /// Update the cache with a new font
    private func updateCache(url: URL, psName: String) {
        loadedFonts[url] = psName
    }
    
    /// Register font data with CoreText and return PostScript name
    @MainActor
    private func registerFontData(_ data: Data) -> String? {
        guard
            let provider = CGDataProvider(data: data as CFData),
            let cgFont = CGFont(provider)
        else {
            Logger.fontLoading.error("Invalid font data")
            return nil
        }
        
        var registrationError: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &registrationError)
        if let err = registrationError?.takeRetainedValue() {
            // Check if font is already registered (error code 105)
            let errorCode = CFErrorGetCode(err)
            if errorCode == 105 {
                // Font already registered, this is fine
                Logger.fontLoading.debug("Font already registered, continuing...")
            } else {
                Logger.fontLoading.error("Font registration failed with code \(errorCode): \(err, privacy: .public)")
                return nil
            }
        }
        
        return cgFont.postScriptName as String?
    }
}
