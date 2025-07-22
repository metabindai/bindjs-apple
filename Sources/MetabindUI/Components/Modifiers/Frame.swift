import SwiftUI

public struct FrameComponent: Component {
    public static var directiveName: String = "frame"
    
    public let width: CGFloat?
    public let height: CGFloat?
    public let alignment: Alignment
}

extension FrameComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        width = directive["width"]
        height = directive["height"]
        alignment = directive["alignment"] ?? .center
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitFrame(self)
    }
}

extension FrameComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(width: width, height: height, alignment: alignment)
    }
}
