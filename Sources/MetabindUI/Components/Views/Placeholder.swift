import SwiftUI

public struct PlaceholderComponent: Component {
    public static var directiveName: String = "Placeholder"
}

extension PlaceholderComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitPlaceholder(self)
    }
}

extension PlaceholderComponent: View {
    public var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
    }
}
