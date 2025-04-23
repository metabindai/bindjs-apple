import SwiftUI

struct FontWidthComponent: Component {
    static var directiveName: String = "fontWidth"
    
    let fontWidth: Font.Width
}

extension FontWidthComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        fontWidth = directive.rawValue() ?? .standard
    }
}

extension FontWidthComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWidth(fontWidth)
    }
}
