import SwiftUI

struct ShadowComponent: AutomaticComponentConvertible {
    var color: ColorComponent = .init(red: 0, green: 0, blue: 0, opacity: 0.5)
    var radius: Double = 0.0
    var x: Double = 0.0
    var y: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.radius),
            ("color", \Self.color),
            ("radius", \Self.radius),
            ("x", \Self.x),
            ("y", \Self.y)
        ]
    }
}

extension ShadowComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.shadow(
            color: color.swiftUI,
            radius: radius,
            x: x,
            y: y
        )
    }
}
