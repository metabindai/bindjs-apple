import SwiftUI

struct CornerRadiusComponent: AutomaticComponentConvertible {
    var radius: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.radius)
        ]
    }
}

extension CornerRadiusComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
