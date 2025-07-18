import SwiftUI

struct TextSelectionComponent: Component {
    static var directiveName: String = "textSelection"
    
    let textSelectability: TextSelectabilityArgument
}

extension TextSelectionComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        textSelectability = directive.rawValue() ?? .enabled
    }
}

extension TextSelectionComponent: ViewModifier {
    func body(content: Content) -> some View {
        if textSelectability == .enabled {
            content
                .textSelection(.enabled)
        } else {
            content
                .textSelection(.disabled)
        }
    }
}
