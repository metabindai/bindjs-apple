import SwiftUI

public struct TransformEffectComponent: Component {
    public static var directiveName: String = "transformEffect"
    
    public let a: CGFloat
    public let b: CGFloat
    public let c: CGFloat
    public let d: CGFloat
    public let tx: CGFloat
    public let ty: CGFloat
}

extension TransformEffectComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        a = directive["a"] ?? 1
        b = directive["b"] ?? 0
        c = directive["c"] ?? 0
        d = directive["d"] ?? 1
        tx = directive["tx"] ?? 0
        ty = directive["ty"] ?? 0
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitTransformEffect(self)
    }
}

extension TransformEffectComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .transformEffect(CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty))
    }
}
