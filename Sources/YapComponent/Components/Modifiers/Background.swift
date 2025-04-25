import SwiftUI

struct BackgroundComponent: Component {
    static var directiveName: String = "background"
    
    let style: Component
}

extension BackgroundComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        style = directive.rawValue().flatMap { makeComponent($0) } ?? EmptyComponent()
    }
}

extension BackgroundComponent: ViewModifier {
    func body(content: Content) -> some View {
        switch style {
        case let color as ColorComponent:
            content.background(color.swiftUI)
        case let linearGradient as LinearGradientComponent:
            content.background(linearGradient.swiftUI)
        case let angularGradient as AngularGradientComponent:
            content.background(angularGradient.swiftUI)
        case let radialGradient as RadialGradientComponent:
            content.background(radialGradient.swiftUI)
        case let ellipticalGradient as EllipticalGradientComponent:
            content.background(ellipticalGradient.swiftUI)
        case let material as MaterialComponent:
            content.background(material.swiftUI)
        case is EmptyComponent:
            content.background()
        default:
            content.background(ComponentView(style))
        }
    }
}
