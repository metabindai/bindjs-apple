import SwiftUI

struct OffsetComponent: AutomaticComponentConvertible {
    var x: Double = 0.0
    var y: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("x", \Self.x),
            ("y", \Self.y)
        ]
    }
}

extension OffsetComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.offset(
            x: x,
            y: y
        )
    }
}
