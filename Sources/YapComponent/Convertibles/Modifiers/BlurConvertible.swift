import SwiftUI

struct BlurConvertible: ComponentConvertible {
    let radius: Double
    
    init(_ component: Component) {
        radius = component.decode("value") ?? component.decode("radius") ?? 0.0
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "radius": radius
        ])
    }
}

extension BlurConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }
}
