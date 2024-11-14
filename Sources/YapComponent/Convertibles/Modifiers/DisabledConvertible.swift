import SwiftUI

struct DisabledConvertible: ComponentConvertible {
    var isActive: Bool
    
    init(_ component: Component) {
        isActive = component.decode("value") ?? true
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": isActive
        ])
    }
}

extension DisabledConvertible: ViewModifier {
        
    public func body(content: Content) -> some View {
        content.disabled(!isActive)
    }
}
