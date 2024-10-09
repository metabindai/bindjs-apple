import SwiftUI

struct EdgeInsetsComponent: AutomaticComponentConvertible {
    var top: Double = 0.0
    var leading: Double = 0.0
    var bottom: Double = 0.0
    var trailing: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("top", \Self.top),
            ("leading", \Self.leading),
            ("bottom", \Self.bottom),
            ("trailing", \Self.trailing)
        ]
    }
}

extension EdgeInsetsComponent {
    static func all(_ length: Double) -> EdgeInsetsComponent {
        EdgeInsetsComponent(top: length, leading: length, bottom: length, trailing: length)
    }
}

extension EdgeInsetsComponent {
    var swiftUI: EdgeInsets {
        EdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }
}
