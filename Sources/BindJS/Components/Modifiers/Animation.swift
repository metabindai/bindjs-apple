import SwiftUI

public struct AnimationModifierComponent: Component {
    public static var directiveName: String = "animation"

    let animation: JSAnimation?
    public let value: String?
}

extension AnimationModifierComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        if let jsonString: String = directive["animation"],
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(JSAnimation.self, from: data) {
            animation = decoded
        } else {
            animation = nil
        }

        value = directive["value"]
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitAnimation(self)
    }
}

extension AnimationModifierComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.animation(animation?.animation(), value: value)
    }
}
