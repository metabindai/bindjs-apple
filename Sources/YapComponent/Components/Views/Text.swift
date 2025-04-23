import SwiftUI

struct TextComponent: Component {
    static var directiveName: String = "Text"
    
    let text: String
    
    init(_ string: String) {
        self.text = string
    }
}

extension TextComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        text = directive.rawValue() ?? ""
    }
}

extension TextComponent: View {
    var body: some View {
        Text(text)
    }
}
