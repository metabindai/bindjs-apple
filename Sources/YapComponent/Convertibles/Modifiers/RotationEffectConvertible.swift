import SwiftUI

struct RotationEffectConvertible: ComponentConvertible {
    let angle: Double
    let anchor: String
    
    init(_ component: Component) {
        angle = component.decode("angle") ?? component.decode("value") ?? 0
        anchor = component.decode("anchor") ?? "center"
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "angle": angle,
            "anchor": anchor
        ])
    }
}

extension RotationEffectConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(angle), anchor: .init(stringValue: anchor))
    }
}
