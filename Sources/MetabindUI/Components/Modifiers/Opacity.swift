import SwiftUI

struct OpacityComponent: Component {
    static var directiveName: String = "opacity"
    
    let opacity: Double
}

extension OpacityComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        opacity = directive.rawValue() ?? 1
    }
}

extension OpacityComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }
}
