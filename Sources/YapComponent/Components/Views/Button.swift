import SwiftUI

struct ButtonComponent: Component {
    static var directiveName: String = "Button"
    
    @EnvironmentObject private var runtime: ComponentRuntime
    
    let label: Component
    let handlerId: String
}

extension ButtonComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        label = directive["label"].flatMap(makeComponent) ?? TextComponent("Button")
        handlerId = directive["handlerId"] ?? ""
    }
}

extension ButtonComponent: View {
    var body: some View {
        Button(action: {
            _ = runtime.callEventHandler(id: handlerId, arguments: [])
        }) {
            ComponentView(label)
        }
    }
}
