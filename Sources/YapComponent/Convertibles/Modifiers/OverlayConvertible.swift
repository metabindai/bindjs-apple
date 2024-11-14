import SwiftUI

struct OverlayConvertible: ComponentConvertible {
    let overlay: AST?
    
    init(_ component: Component) {
        overlay = component.props["value"]
    }
    
    var component: Component {
        if let overlay = overlay {
            return Component(type: Self.componentName, props: ["value": overlay])
        } else {
            return Component(type: Self.componentName, props: [:])
        }
    }
}

extension OverlayConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let overlay {
            content.overlay(ComponentView(overlay))
        } else {
            content
        }
    }
}
