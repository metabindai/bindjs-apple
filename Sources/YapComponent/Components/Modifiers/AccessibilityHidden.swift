import SwiftUI

struct AccessibilityHiddenComponent: Component {
    static var directiveName: String = "accessibilityHidden"
    
    let isActive: Bool
}

extension AccessibilityHiddenComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension AccessibilityHiddenComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityHidden(isActive)
    }
}
