import SwiftUI

struct PaddingComponent: AutomaticComponentConvertible {
    var edges: EdgeSetComponent = .all
    var insets: EdgeInsetsComponent?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("edges", \Self.edges),
            ("insets", \Self.insets)
        ]
    }
}

extension PaddingComponent: ViewModifier {

    func body(content: Content) -> some View {
        content
            .modifier(_PaddingLayout(edges: edges.swiftUI, insets: insets?.swiftUI))
    }
}
