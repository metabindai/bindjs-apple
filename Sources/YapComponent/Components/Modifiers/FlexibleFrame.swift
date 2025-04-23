import SwiftUI

struct FlexibleFrameComponent: Component {
    static var directiveName: String = "frame"
    
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment
}

extension FlexibleFrameComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        minWidth = directive["minWidth"]
        maxWidth = directive["maxWidth"]
        minHeight = directive["minHeight"]
        maxHeight = directive["maxHeight"]
        alignment = directive["alignment"] ?? .center
    }
}

extension FlexibleFrameComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, alignment: alignment)
    }
}
