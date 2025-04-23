import SwiftUI

struct MonospacedComponent: Component {
    static var directiveName: String = "monospaced"
    
    let isActive: Bool
}

extension MonospacedComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension MonospacedComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .monospaced(isActive)
    }
}
