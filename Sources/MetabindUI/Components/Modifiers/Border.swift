import SwiftUI

struct BorderComponent: Component {
    static var directiveName: String = "border"
    
    let style: Component
    let width: CGFloat
}

extension BorderComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        style = directive["style"].flatMap { makeComponent($0) } ?? EmptyComponent()
        width = directive["width"] ?? 1
    }
}

extension BorderComponent: ViewModifier {
    func body(content: Content) -> some View {
        switch style {
        case let color as ColorComponent:
            content.border(color.swiftUI, width: width)
        case let linearGradient as LinearGradientComponent:
            content.border(linearGradient.swiftUI, width: width)
        case let angularGradient as AngularGradientComponent:
            content.border(angularGradient.swiftUI, width: width)
        case let radialGradient as RadialGradientComponent:
            content.border(radialGradient.swiftUI, width: width)
        case let ellipticalGradient as EllipticalGradientComponent:
            content.border(ellipticalGradient.swiftUI, width: width)
        case let material as MaterialComponent:
            content.border(material.swiftUI, width: width)
        default:
            content.border(.primary, width: width)
        }
    }
}
