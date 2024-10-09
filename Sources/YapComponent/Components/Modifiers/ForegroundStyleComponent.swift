import SwiftUI

struct ForegroundStyleComponent: AutomaticComponentConvertible {
    var color: ColorComponent?
    var gradient: LinearGradientComponent?
    var material: MaterialComponent?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("color", \Self.color),
            ("gradient", \Self.gradient),
            ("material", \Self.material),
        ]
    }
}

extension ForegroundStyleComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if let color {
            content.foregroundStyle(color.swiftUI)
        } else if let gradient {
            content.foregroundStyle(gradient.swiftUI)
        } else if let material {
            content.foregroundStyle(material.swiftUI)
        }
    }
}
