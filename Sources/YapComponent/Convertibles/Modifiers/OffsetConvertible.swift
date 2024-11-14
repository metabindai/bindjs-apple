import SwiftUI

struct OffsetConvertible: ComponentConvertible {
    var x: Double
    var y: Double
    
    init(_ component: Component) {
        x = component.decode("x") ?? 0.0
        y = component.decode("y") ?? 0.0
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

extension OffsetConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.offset(x: x, y: y)
    }
}
