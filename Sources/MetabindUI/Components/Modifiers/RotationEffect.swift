import SwiftUI

struct RotationEffectComponent: Component {
    static var directiveName: String = "rotationEffect"
    
    let angle: Angle
    let anchor: UnitPoint
}

extension RotationEffectComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        angle = Angle(degrees: directive.rawValue() ?? directive["degrees"] ?? 0)
        anchor = directive["anchor"] ?? .center
    }
}

extension RotationEffectComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(angle, anchor: anchor)
    }
}
