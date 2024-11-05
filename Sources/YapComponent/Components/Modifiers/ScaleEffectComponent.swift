import SwiftUI

struct ScaleEffectComponent: AutomaticComponentConvertible {
    var x: Double = 1.0
    var y: Double = 1.0
    var xy: Double?
    var anchor: UnitPointComponent = .center
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.xy),
            ("x", \Self.x),
            ("y", \Self.y),
            ("anchor", \Self.anchor)
        ]
    }
}

extension ScaleEffectComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.scaleEffect(
            x: xy ?? x,
            y: xy ?? y,
            anchor: anchor.swiftUI
        )
    }
}
