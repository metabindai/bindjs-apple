import SwiftUI

struct TransformEffectComponent: Component {
    static var directiveName: String = "transformEffect"
    
    let a: CGFloat
    let b: CGFloat
    let c: CGFloat
    let d: CGFloat
    let tx: CGFloat
    let ty: CGFloat
}

extension TransformEffectComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        a = directive["a"] ?? 1
        b = directive["b"] ?? 0
        c = directive["c"] ?? 0
        d = directive["d"] ?? 1
        tx = directive["tx"] ?? 0
        ty = directive["ty"] ?? 0
    }
}

extension TransformEffectComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transformEffect(CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty))
    }
}
