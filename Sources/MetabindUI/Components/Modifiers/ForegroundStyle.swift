import SwiftUI

public struct ForegroundStyleComponent: Component {
    public static var directiveName: String = "foregroundStyle"
    
    public var style: Component
}

extension ForegroundStyleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        style = directive.rawValue().flatMap { makeComponent($0) } ?? EmptyComponent()
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitForegroundStyle(self)
    }
}

extension ForegroundStyleComponent: ViewModifier {
    public func body(content: Content) -> some View {
        switch style {
        case let color as ColorComponent:
            content.foregroundStyle(color.swiftUI)
        case let linearGradient as LinearGradientComponent:
            content.foregroundStyle(linearGradient.swiftUI)
        case let angularGradient as AngularGradientComponent:
            content.foregroundStyle(angularGradient.swiftUI)
        case let radialGradient as RadialGradientComponent:
            content.foregroundStyle(radialGradient.swiftUI)
        case let ellipticalGradient as EllipticalGradientComponent:
            content.foregroundStyle(ellipticalGradient.swiftUI)
        case let material as MaterialComponent:
            content.foregroundStyle(material.swiftUI)
        case let call as ComponentCall:
            content.modifier(ForegroundStyleComponent(style: call.wrapped))
        default:
            content
        }
    }
}
