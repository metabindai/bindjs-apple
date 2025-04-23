import SwiftUI

struct ColorSchemeComponent: Component {
    static var directiveName: String = "colorScheme"
    
    let colorScheme: ColorScheme
}

extension ColorSchemeComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        colorScheme = directive.rawValue() ?? .light
    }
}

extension ColorSchemeComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .colorScheme(colorScheme)
    }
}
