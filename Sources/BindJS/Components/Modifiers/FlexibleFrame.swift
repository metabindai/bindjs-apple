import SwiftUI

/// A frame with a minimum or maximum length. A fixed `width` or `height` in the
/// same frame pins that axis (minimum, ideal and maximum all equal it), which
/// sizes exactly as SwiftUI's `.frame(width:)` does on that axis.
public struct FlexibleFrameComponent: Component {
    public static var directiveName: String = "frame"
    
    public var width: CGFloat?
    public var height: CGFloat?
    public var minWidth: CGFloat?
    public var maxWidth: CGFloat?
    public var minHeight: CGFloat?
    public var maxHeight: CGFloat?
    public var alignment: Alignment
}

extension FlexibleFrameComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        width = directive["width"]
        height = directive["height"]
        minWidth = directive["minWidth"]
        maxWidth = directive["maxWidth"]
        minHeight = directive["minHeight"]
        maxHeight = directive["maxHeight"]
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

    private func fixed(_ value: CGFloat?) -> CGFloat? {
        guard let value, value >= 0, value.isFinite else { return nil }
        return value
    }

    public func body(content: Content) -> some View {
        let width = fixed(width)
        let height = fixed(height)
        return content
            .frame(
                minWidth: width ?? sanitize(minWidth),
                idealWidth: width,
                maxWidth: width ?? sanitize(maxWidth),
                minHeight: height ?? sanitize(minHeight),
                idealHeight: height,
                maxHeight: height ?? sanitize(maxHeight),
                alignment: alignment
            )
    }
}
