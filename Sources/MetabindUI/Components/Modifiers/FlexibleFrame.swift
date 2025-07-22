import SwiftUI

public struct FlexibleFrameComponent: Component {
    public static var directiveName: String = "frame"
    
    public let minWidth: CGFloat?
    public let maxWidth: CGFloat?
    public let minHeight: CGFloat?
    public let maxHeight: CGFloat?
    public let alignment: Alignment
}

extension FlexibleFrameComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
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
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, alignment: alignment)
    }
}
