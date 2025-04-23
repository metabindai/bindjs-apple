import SwiftUI

struct BlurComponent: Component {
    static var directiveName: String = "blur"
    
    let radius: CGFloat
}

extension BlurComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        radius = directive.rawValue() ?? 0
    }
}

extension BlurComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .blur(radius: radius)
    }
}
