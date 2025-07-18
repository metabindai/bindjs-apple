import SwiftUI

struct ContrastComponent: Component {
    static var directiveName: String = "contrast"
    
    let contrast: Double
}

extension ContrastComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        contrast = directive.rawValue() ?? 1
    }
}

extension ContrastComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contrast(contrast)
    }
}
