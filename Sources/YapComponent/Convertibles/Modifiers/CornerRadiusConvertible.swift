import SwiftUI

struct CornerRadiusConvertible: ComponentConvertible {
    
    let cornerRadius: Double
    
    init(_ component: Component) {
        cornerRadius = component.decode("cornerRadius") ?? component.decode("value") ?? 0
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "cornerRadius": cornerRadius
            ]
        )
    }
}

extension CornerRadiusConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
