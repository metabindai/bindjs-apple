import SwiftUI

struct FontWeightComponent: Component {
    static var directiveName: String = "fontWeight"
    
    let fontWeight: Font.Weight
}

extension FontWeightComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        fontWeight = directive.rawValue() ?? .regular
    }
}

extension FontWeightComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(fontWeight)
    }
}
