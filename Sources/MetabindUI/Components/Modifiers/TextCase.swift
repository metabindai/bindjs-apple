import SwiftUI

struct TextCaseComponent: Component {
    static var directiveName: String = "textCase"
    
    let textCase: Text.Case?
}

extension TextCaseComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        textCase = directive.rawValue()
    }
}

extension TextCaseComponent: ViewModifier {
    func body(content: Content) -> some View {
        if let textCase {
            content
                .textCase(textCase)
        } else {
            content
        }
    }
}
