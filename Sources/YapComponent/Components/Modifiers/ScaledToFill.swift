import SwiftUI

struct ScaledToFillComponent: Component {
    static var directiveName: String = "scaledToFill"
}

extension ScaledToFillComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension ScaledToFillComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
    }
}
