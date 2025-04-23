import SwiftUI

struct UnderlineComponent: Component {
    static var directiveName: String = "underline"
    
    var isActive: Bool
}

extension UnderlineComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension UnderlineComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .underline(isActive)
    }
}
