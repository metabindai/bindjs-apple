import SwiftUI

public struct ShadowConvertible: ComponentConvertible {
    let color: ColorConvertible
    let radius: Double
    let x: Double
    let y: Double
    
    init(_ component: Component) {
        color = component.decode("color") ?? .shadow
        radius = component.decode("radius") ?? component.decode("value") ?? 10.0
        x = component.decode("x") ?? 0.0
        y = component.decode("y") ?? 0.0
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "color": color.component,
            "radius": radius,
            "x": x,
            "y": y
        ])
    }
}

extension ShadowConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.shadow(color: color.swiftUI, radius: radius, x: x, y: y)
    }
}

