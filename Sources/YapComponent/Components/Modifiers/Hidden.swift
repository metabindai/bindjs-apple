import SwiftUI

struct HiddenComponent: Component {
    static var directiveName: String = "hidden"
}

extension HiddenComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension HiddenComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .hidden()
    }
}
