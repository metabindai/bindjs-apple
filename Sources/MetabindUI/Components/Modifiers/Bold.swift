import SwiftUI

struct BoldComponent: Component {
    static var directiveName: String = "bold"
    
    var isActive: Bool
}

extension BoldComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension BoldComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold(isActive)
    }
}
