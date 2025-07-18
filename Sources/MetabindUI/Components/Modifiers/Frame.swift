import SwiftUI

struct FrameComponent: Component {
    static var directiveName: String = "frame"
    
    let width: CGFloat?
    let height: CGFloat?
    let alignment: Alignment
}

extension FrameComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        width = directive["width"]
        height = directive["height"]
        alignment = directive["alignment"] ?? .center
    }
}

extension FrameComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height, alignment: alignment)
    }
}
