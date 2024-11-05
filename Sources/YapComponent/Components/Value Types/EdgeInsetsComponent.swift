import SwiftUI

struct EdgeInsetsComponent: AutomaticComponentConvertible {
    var top: Double = 0.0
    var leading: Double = 0.0
    var bottom: Double = 0.0
    var trailing: Double = 0.0
    var all: Double?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("top", \Self.top),
            ("leading", \Self.leading),
            ("bottom", \Self.bottom),
            ("trailing", \Self.trailing),
            ("rawValue", \Self.all)
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
            top: all ?? top,
            leading: all ?? leading,
            bottom: all ?? bottom,
            trailing: all ?? trailing
        )
    }
}
