import SwiftUI

struct StrikethroughComponent: Component {
    static var directiveName: String = "strikethrough"
    
    let isActive: Bool
}

extension StrikethroughComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension StrikethroughComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .strikethrough(isActive)
    }
}
