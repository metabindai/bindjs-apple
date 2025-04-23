import SwiftUI

struct OnAppearComponent: Component {
    static var directiveName: String = "onAppear"
    
    @EnvironmentObject private var runtime: ComponentRuntime
    
    let handlerId: String
}

extension OnAppearComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        handlerId = directive["handlerId"] ?? ""
    }
}

extension OnAppearComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                _ = runtime.callEventHandler(id: handlerId, arguments: [])
            }
    }
}
