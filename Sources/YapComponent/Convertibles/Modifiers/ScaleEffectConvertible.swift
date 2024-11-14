import SwiftUI

public struct ScaleEffectConvertible: ComponentConvertible {
    var x: Double
    var y: Double
    
    init(_ component: Component) {
        x = component.decode("x") ?? 1.0
        y = component.decode("y") ?? 1.0
        if let value: Double = component.decode("value") {
            x = value
            y = value
        }
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "x": x,
            "y": y
        ])
    }
}

extension ScaleEffectConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.scaleEffect(x: x, y: y)
    }
}
