import SwiftUI

public struct FlexibleFrameComponent: Component {
    public static var directiveName: String = "frame"
    
    public var minWidth: CGFloat?
    public var maxWidth: CGFloat?
    public var minHeight: CGFloat?
    public var maxHeight: CGFloat?
    /// A fixed size given alongside the bounds, as in `frame({ maxWidth: Infinity, height: 220 })`.
    /// SwiftUI has no single `frame` taking both, so it is applied as a fixed frame inside the
    /// flexible one, which is what chaining the two calls would do.
    public var width: CGFloat?
    public var height: CGFloat?
    public var alignment: Alignment
}

extension FlexibleFrameComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        minWidth = directive["minWidth"]
        maxWidth = directive["maxWidth"]
        minHeight = directive["minHeight"]
        maxHeight = directive["maxHeight"]
        width = directive["width"]
        height = directive["height"]
        alignment = directive["alignment"] ?? .center
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitFlexibleFrame(self)
    }
}

extension FlexibleFrameComponent: ViewModifier {
    private func sanitize(_ value: CGFloat?) -> CGFloat? {
        guard let value, value >= 0, !value.isNaN else { return nil }
        return value
    }

    private func sanitizeFixed(_ value: CGFloat?) -> CGFloat? {
        guard let value, value >= 0, value.isFinite else { return nil }
        return value
    }

    public func body(content: Content) -> some View {
        content
            .frame(width: sanitizeFixed(width), height: sanitizeFixed(height), alignment: alignment)
            .frame(
                minWidth: sanitize(minWidth),
                maxWidth: sanitize(maxWidth),
                minHeight: sanitize(minHeight),
                maxHeight: sanitize(maxHeight),
                alignment: alignment
            )
    }
}
