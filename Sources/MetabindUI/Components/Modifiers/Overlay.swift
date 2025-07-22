import SwiftUI

public struct OverlayComponent: Component {
    public static var directiveName: String = "overlay"
    
    public let content: [Component]
    public let alignment: Alignment
}

extension OverlayComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.alignment = directive["alignment"] ?? .center
        self.content = directive.children.compactMap { makeComponent($0) }
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitOverlay(self)
    }
}

extension OverlayComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.overlay(alignment: alignment) {
            ForEach(self.content.indices, id: \.self) { index in
                ComponentView(self.content[index])
            }
        }
    }
}
