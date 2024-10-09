import SwiftUI

struct BorderComponent: AutomaticComponentConvertible {
    var color: ColorComponent?
    var gradient: LinearGradientComponent?
    var width: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("color", \Self.color),
            ("gradient", \Self.gradient),
            ("width", \Self.width)
        ]
    }
}

extension BorderComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if let color {
            content.border(color.swiftUI, width: width)
        } else if let gradient {
            content.border(gradient.swiftUI, width: width)
        } else {
            content
        }
    }
}
