import SwiftUI
import QuickLook

public struct QuickLookPreviewARComponent: Component {
    public static var directiveName: String = "quickLookPreviewAR"
    
    let isPresented: Bool?
    let setIsPresentedId: String?
    let url: String
    let environmentId: String
    let onLoadingChangedId: String?
    
    @EnvironmentObject private var context: BindJSContext
}

extension QuickLookPreviewARComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        self.isPresented = directive["isPresented"]
        self.setIsPresentedId = directive["setIsPresentedId"]
        self.url = directive["url"] ?? ""
        self.environmentId = directive["environmentId"] ?? ""
        self.onLoadingChangedId = directive["onLoadingChangedId"]
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitQuickLookPreviewAR(self)
    }
}

extension QuickLookPreviewARComponent: ViewModifier {
    public func body(content: Content) -> some View {
        ARModelView(
            url: url,
            isPresented: isPresented ?? false,
            content: content,
            onPresentationChange: { newValue in
                if let setIsPresentedId {
                    context.restoreEnvironment(id: environmentId)
                    context.callEventHandler(id: setIsPresentedId, arguments: newValue)
                }
            },
            onLoadingChanged: { isLoading in
                if let onLoadingChangedId {
                    context.restoreEnvironment(id: environmentId)
                    context.callEventHandler(id: onLoadingChangedId, arguments: isLoading)
                }
            }
        )
    }
}

struct ARModelView<Content: View>: View {
    let url: String
    let isPresented: Bool
    let content: Content
    let onPresentationChange: (Bool) -> Void
    let onLoadingChanged: (Bool) -> Void
    
    @State private var isLoading = false
    @State private var dataSource: SimpleQLDataSource?
    
    var body: some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue, let urlObject = URL(string: url) {
                    openAR(url: urlObject)
                }
            }
            .onChange(of: isLoading) { newValue in
                onLoadingChanged(newValue)
            }
    }
    
    private func openAR(url: URL) {
        let fileName = url.lastPathComponent
        let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
        // Check if already cached
        if FileManager.default.fileExists(atPath: localURL.path) {
            // Show loading briefly for cached files for consistent UX
            isLoading = true
            presentQuickLook(localURL)
            return
        }
        
        // Start loading state for download
        isLoading = true
        
        // Download the model
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else { 
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onPresentationChange(false)
                }
                return 
            }
            
            do {
                // Remove any existing file and move the downloaded file
                try? FileManager.default.removeItem(at: localURL)
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                DispatchQueue.main.async {
                    self.presentQuickLook(localURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onPresentationChange(false)
                }
            }
        }
        
        task.resume()
    }
    
    private func presentQuickLook(_ fileURL: URL) {
        let preview = QLPreviewController()
        dataSource = SimpleQLDataSource(url: fileURL)
        preview.dataSource = dataSource
        
        if let root = Self.topViewController() {
            root.present(preview, animated: true) {
                // Only set loading to false after QuickLook is fully presented
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onPresentationChange(false)
                }
            }
        } else {
            // Fallback if no root view controller found
            DispatchQueue.main.async {
                self.isLoading = false
                self.onPresentationChange(false)
            }
        }
    }
    
    private static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
        .first) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

private class SimpleQLDataSource: NSObject, QLPreviewControllerDataSource {
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return url as QLPreviewItem
    }
}
