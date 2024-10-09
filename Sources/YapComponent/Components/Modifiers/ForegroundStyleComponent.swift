import SwiftUI

struct ForegroundStyleComponent: AutomaticComponentConvertible {
    var color: ColorComponent?
    var gradient: LinearGradientComponent?
    var material: MaterialComponent?
    var name: String?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("color", \Self.color),
            ("gradient", \Self.gradient),
            ("material", \Self.material),
            ("name", \Self.name)
        ]
    }
}

struct ForegroundStyleComponentModifier: ViewModifier {
    
    @Environment(\.componentContext) var context
    
    let foregroundStyle: ForegroundStyleComponent
    
    init(_ foregroundStyle: ForegroundStyleComponent) {
        self.foregroundStyle = foregroundStyle
    }
    
    func body(content: Content) -> some View {
        if let color = foregroundStyle.color {
            content.foregroundStyle(color.swiftUI)
        } else if let gradient = foregroundStyle.gradient {
            content.foregroundStyle(gradient.swiftUI)
        } else if let material = foregroundStyle.material {
            content.foregroundStyle(material.swiftUI)
        } else if let name = foregroundStyle.name {
            if let component = context.get(name) as? Callable, let resolved = component.callAsFunction([:], context: context) as? Component, case let converted = convertComponent(resolved) {
                switch converted {
                case let color as ColorComponent:
                    content.foregroundStyle(color.swiftUI)
                case let material as MaterialComponent:
                    content.foregroundStyle(material.swiftUI)
                case let gradient as LinearGradientComponent:
                    content.foregroundStyle(gradient.swiftUI)
                default:
                    content
                }
            }
        }
    }
}
