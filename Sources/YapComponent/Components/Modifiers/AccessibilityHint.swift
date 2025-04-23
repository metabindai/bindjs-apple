import SwiftUI

struct AccessibilityHintComponent: Component {
    static var directiveName: String = "accessibilityHint"
    
    let hint: String
}

extension AccessibilityHintComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        hint = directive.rawValue() ?? ""
    }
}

extension AccessibilityHintComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityHint(hint)
    }
}
