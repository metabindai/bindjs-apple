import SwiftUI

struct RotationEffectComponent: AutomaticComponentConvertible {
    var angle: Double = 0.0
    var anchor: UnitPointComponent = .center
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("angle", \Self.angle),
            ("anchor", \Self.anchor)
        ]
    }
}

extension RotationEffectComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.rotationEffect(
            .degrees(angle),
            anchor: anchor.swiftUI
        )
    }
}
