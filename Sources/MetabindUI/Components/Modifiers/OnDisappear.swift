import SwiftUI

struct OnDisappearComponent: Component {
    static var directiveName: String = "onDisappear"
    
    @EnvironmentObject private var context: ComponentContext
    
    let handlerId: String
}

extension OnDisappearComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        handlerId = directive["handlerId"] ?? ""
    }
}

extension OnDisappearComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onDisappear {
                _ = context.callEventHandler(id: handlerId, arguments: [])
            }
    }
}
