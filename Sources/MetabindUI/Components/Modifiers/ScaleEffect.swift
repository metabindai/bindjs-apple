import SwiftUI

struct ScaleEffectComponent: Component {
    static var directiveName: String = "scaleEffect"
    
    let x: CGFloat
    let y: CGFloat
    let anchor: UnitPoint
}

extension ScaleEffectComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        x = directive["x"] ?? directive.rawValue() ?? 1
        y = directive["y"] ?? directive.rawValue() ?? 1
        anchor = directive["anchor"] ?? .center
    }
}

extension ScaleEffectComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaleEffect(x: x, y: y, anchor: anchor)
    }
}
