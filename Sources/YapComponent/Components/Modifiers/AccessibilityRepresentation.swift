import SwiftUI

struct AccessibilityRepresentationComponent: Component {
    static var directiveName: String = "accessibilityRepresentation"
    
    let representation: Component
}

extension AccessibilityRepresentationComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        representation = directive.rawValue().flatMap { makeComponent($0) } ?? EmptyComponent()
    }
}

extension AccessibilityRepresentationComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityRepresentation {
                ComponentView(representation)
            }
    }
}
