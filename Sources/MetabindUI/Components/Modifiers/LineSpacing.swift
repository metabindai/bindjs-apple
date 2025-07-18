import SwiftUI

struct LineSpacingComponent: Component {
    static var directiveName: String = "lineSpacing"
    
    let lineSpacing: CGFloat
}

extension LineSpacingComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        lineSpacing = directive.rawValue() ?? 0
    }
}

extension LineSpacingComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineSpacing(lineSpacing)
    }
}
