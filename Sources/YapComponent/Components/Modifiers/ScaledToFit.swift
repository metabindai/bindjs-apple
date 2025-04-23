import SwiftUI

struct ScaledToFitComponent: Component {
    static var directiveName: String = "scaledToFit"
}

extension ScaledToFitComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension ScaledToFitComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
    }
}
