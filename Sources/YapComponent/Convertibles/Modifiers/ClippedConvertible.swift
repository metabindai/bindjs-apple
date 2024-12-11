import SwiftUI

struct ClippedConvertible: ComponentConvertible {
    
    var isActive: Bool = true
    
    init(_ component: Component) {
        self.isActive = component.decode("value") ?? component.decode("isActive") ?? true
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": isActive
        ])
    }
}

extension ClippedConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if isActive {
            content.clipped()
        } else {
            content
        }
    }
}
