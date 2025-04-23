import SwiftUI

struct FontDesignComponent: Component {
    static var directiveName: String = "fontDesign"
    
    let fontDesign: Font.Design
}

extension FontDesignComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        fontDesign = directive.rawValue() ?? .default
    }
}

extension FontDesignComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontDesign(fontDesign)
    }
}
