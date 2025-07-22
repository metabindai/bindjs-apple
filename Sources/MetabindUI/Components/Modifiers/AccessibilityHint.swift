import SwiftUI

public struct AccessibilityHintComponent: Component {
    public static var directiveName: String = "accessibilityHint"
    
    public let hint: String
}

extension AccessibilityHintComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        hint = directive.rawValue() ?? ""
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitAccessibilityHint(self)
    }
}

extension AccessibilityHintComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .accessibilityHint(hint)
    }
}
