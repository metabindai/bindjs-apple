import Foundation
import CoreText
import SwiftUI

struct FontCustomComponent: Component {
    static var directiveName: String = "FontCustom"
    
    // MARK: — Modifier State
    @State private var postScriptName: String?
    @State private var isLoading = false
    
    let family: String
    let size: CGFloat
    let url: URL?
}

extension FontCustomComponent {
    init?(from directive: Directive) {
        self.family = directive["family"] ?? "Not Specified"
        self.size = directive["size"] ?? 17.0
        self.url = directive["url"]
    }
}

extension FontCustomComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content
        // 1)  Use the custom font if loaded, else fallback:
            .font(makeFont())
        // 2)  Kick off download when this view appears / url changes:
            .task(id: url) {
                await loadFontIfNeeded()
            }
    }
    
    // MARK: — Helper: choose the Font to apply
    private func makeFont() -> Font {
        if let psName = postScriptName {
            // We have a downloaded font → use it
            return .custom(psName, size: size)
        } else if url != nil {
            // We're still loading → use system for now
            return .system(size: size)
        } else {
            // No URL was provided → try using the family name locally
            return .custom(family, size: size)
        }
    }
    
    // MARK: — Async loader
    private func loadFontIfNeeded() async {
        guard
            !isLoading,
            postScriptName == nil,
            let fontURL = url
        else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Ask our FontCache actor
            let name = try await FontCache.shared.postScriptName(for: fontURL)
            // Bounce back to the main thread to update @State
            await MainActor.run {
                self.postScriptName = name
            }
        } catch {
            debugPrint("FontCustomComponent failed to load \(fontURL): \(error)")
        }
    }
}

public enum FontCacheError: Error {
    case downloadFailed(Error)
    case invalidFontData
    case registrationFailed(CFError)
}

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
        try? FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
    }
    
    /// Downloads (or reads from disk) the font at `url`, registers it once,
    /// and returns its PostScript name.
    public func postScriptName(for url: URL) async throws -> String {
        // 1) Reuse in-memory if already loaded
        if let existing = loadedFonts[url] {
            return existing
        }
        
        // 2) Compute local file URL in Caches/Fonts
        let localFile = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        
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
            data = try Data(contentsOf: localFile)
        } else {
            do {
                let (downloaded, _) = try await URLSession.shared.data(from: url)
                data = downloaded
                try data.write(to: localFile, options: .atomic)
            } catch {
                throw FontCacheError.downloadFailed(error)
            }
        }
        
        // 5) Wrap in CGFont and register with CoreText
        guard
            let provider = CGDataProvider(data: data as CFData),
            let cgFont   = CGFont(provider)
        else {
            throw FontCacheError.invalidFontData
        }
        
        var registrationError: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &registrationError)
        if let err = registrationError?.takeRetainedValue() {
            throw FontCacheError.registrationFailed(err)
        }
        
        // 6) Extract and cache its PostScript name
        guard let psName = cgFont.postScriptName as String? else {
            throw FontCacheError.invalidFontData
        }
        loadedFonts[url] = psName
        return psName
    }
}
