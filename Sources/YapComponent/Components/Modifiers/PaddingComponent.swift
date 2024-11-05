import SwiftUI

struct PaddingComponent: AutomaticComponentConvertible {
    var edges: EdgeSetComponent = .all
    var insets: EdgeInsetsComponent?
    var rawValue: Double?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("edges", \Self.edges),
            ("insets", \Self.insets),
            ("rawValue", \Self.rawValue)
        ]
    }
}

extension PaddingComponent: ViewModifier {

    func body(content: Content) -> some View {
        if let rawValue {
            content.padding(rawValue)
        } else {
            content
                .modifier(_PaddingLayout(edges: edges.swiftUI, insets: insets?.swiftUI))
        }
    }
}
