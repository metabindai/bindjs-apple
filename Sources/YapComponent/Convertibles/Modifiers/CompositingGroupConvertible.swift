import SwiftUI

struct CompositingGroupConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension CompositingGroupConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.compositingGroup()
    }
}
