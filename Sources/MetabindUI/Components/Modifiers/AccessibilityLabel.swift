import SwiftUI

struct AccessibilityLabelComponent: Component {
    static var directiveName: String = "accessibilityLabel"
    
    let label: String
}

extension AccessibilityLabelComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        label = directive.rawValue() ?? ""
    }
}

extension AccessibilityLabelComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
    }
}
