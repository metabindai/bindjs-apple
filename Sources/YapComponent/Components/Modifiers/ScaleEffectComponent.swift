import SwiftUI

struct ScaleEffectComponent: AutomaticComponentConvertible {
    var x: Double = 1.0
    var y: Double = 1.0
    var anchor: UnitPointComponent = .center
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("x", \Self.x),
            ("y", \Self.y),
            ("anchor", \Self.anchor)
        ]
    }
}

extension ScaleEffectComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.scaleEffect(
            x: x,
            y: y,
            anchor: anchor.swiftUI
        )
    }
}
