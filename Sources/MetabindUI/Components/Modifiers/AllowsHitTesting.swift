import SwiftUI

struct AllowsHitTestingComponent: Component {
    static var directiveName: String = "allowsHitTestingComponent"
    
    let isActive: Bool
}

extension AllowsHitTestingComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        isActive = directive.rawValue() ?? true
    }
}

extension AllowsHitTestingComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(isActive)
    }
}
