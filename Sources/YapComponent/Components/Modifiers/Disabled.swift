import SwiftUI

struct DisabledComponent: Component {
    static var directiveName: String = "disabled"
    
    let isActive: Bool
}

extension DisabledComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension DisabledComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .disabled(isActive)
    }
}
