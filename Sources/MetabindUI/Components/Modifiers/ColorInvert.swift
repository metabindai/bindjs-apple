import SwiftUI

struct ColorInvertComponent: Component {
    static var directiveName: String = "colorInvert"
}

extension ColorInvertComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension ColorInvertComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .colorInvert()
    }
}
