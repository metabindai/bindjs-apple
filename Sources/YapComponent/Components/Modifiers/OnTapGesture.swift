import SwiftUI

struct OnTapGestureComponent: Component {
    static var directiveName: String = "onTapGesture"
    
    @EnvironmentObject private var runtime: ComponentRuntime
    
    let count: Int
    let handlerId: String
}

extension OnTapGestureComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        count = directive["count"] ?? 1
        handlerId = directive["handlerId"] ?? ""
    }
}

extension OnTapGestureComponent: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture(count: count) {
            _ = runtime.callEventHandler(id: handlerId, arguments: [])
        }
    }
}
