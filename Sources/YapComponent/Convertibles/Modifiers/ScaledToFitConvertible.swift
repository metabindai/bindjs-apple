import SwiftUI

struct ScaledToFitConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension ScaledToFitConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.scaledToFit()
    }
}
