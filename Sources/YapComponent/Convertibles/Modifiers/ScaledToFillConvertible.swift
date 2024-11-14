import SwiftUI

struct ScaledToFillConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension ScaledToFillConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.scaledToFill()
    }
}
