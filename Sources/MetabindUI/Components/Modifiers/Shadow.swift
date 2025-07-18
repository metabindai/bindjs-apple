import SwiftUI

struct ShadowComponent: Component {
    static var directiveName: String = "shadow"
    
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension ShadowComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        color = (directive["color"].flatMap(makeComponent(_:)) as? ColorComponent)?.swiftUI ?? .black.opacity(0.3)
        radius = directive["radius"] ?? 10
        x = directive["x"] ?? 0
        y = directive["y"] ?? 10
    }
}

extension ShadowComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}
