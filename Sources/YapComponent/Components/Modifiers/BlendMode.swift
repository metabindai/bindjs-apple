import SwiftUI

struct BlendModeComponent: Component {
    static var directiveName: String = "blendMode"
    
    let blendMode: BlendMode
}

extension BlendModeComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        blendMode = directive.rawValue() ?? .normal
    }
}

extension BlendModeComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .blendMode(blendMode)
    }
}
