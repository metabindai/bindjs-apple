import SwiftUI

struct DividerComponent: Component {
    static var directiveName: String = "Divider"
}

extension DividerComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension DividerComponent: View {
    var body: some View {
        Divider()
    }
}
