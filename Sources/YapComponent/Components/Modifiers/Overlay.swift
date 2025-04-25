import SwiftUI

struct OverlayComponent: Component {
    static var directiveName: String = "overlay"
    
    let content: [Component]
    let alignment: Alignment
}

extension OverlayComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.alignment = directive["alignment"] ?? .center
        self.content = directive.children.compactMap { makeComponent($0) }
    }
}

extension OverlayComponent: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: alignment) {
            ForEach(self.content.indices, id: \.self) { index in
                ComponentView(self.content[index])
            }
        }
    }
}
