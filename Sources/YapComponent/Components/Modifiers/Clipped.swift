import SwiftUI

struct ClippedComponent: Component {
    static var directiveName: String = "clipped"
}

extension ClippedComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension ClippedComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipped()
    }
}
