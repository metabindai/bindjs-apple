import SwiftUI

struct ItalicComponent: Component {
    static var directiveName: String = "italic"
    
    var isActive: Bool
}

extension ItalicComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension ItalicComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .italic(isActive)
    }
}
