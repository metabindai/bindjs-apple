import SwiftUI

/// A frame with a minimum or maximum length. A fixed `width` or `height` in the
/// same frame is a fixed frame inside the flexible one, as SwiftUI's
/// `.frame(width:height:).frame(minWidth:…)` and as the web and Android
/// renderers apply it: `{ maxWidth: .infinity, height: 240 }` is full width and
/// 240pt tall, and `{ width: 100, maxWidth: 50 }` is 50pt wide.
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

    @ViewBuilder
    public func body(content: Content) -> some View {
        let width = fixed(width)
        let height = fixed(height)
        if width != nil || height != nil {
            bounded(content.frame(width: width, height: height, alignment: alignment))
        } else {
            bounded(content)
        }
    }

    private func bounded(_ view: some View) -> some View {
        view.frame(
            minWidth: sanitize(minWidth),
            maxWidth: sanitize(maxWidth),
            minHeight: sanitize(minHeight),
            maxHeight: sanitize(maxHeight),
            alignment: alignment
        )
    }
}
