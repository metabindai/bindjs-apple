import SwiftUI

public struct OnChangeComponent: Component {
    public static var directiveName: String = "onChange"

    @EnvironmentObject private var context: BindJSContext

    public let watcherId: String
}

extension OnChangeComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        watcherId = directive["watcherId"] ?? ""
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitOnChange(self)
    }
}

extension OnChangeComponent: ViewModifier {
    public func body(content: Content) -> some View {
        let triggerValue = context.restoreOnChangeTrigger(id: watcherId)

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            content
                .onChange(of: triggerValue) { _, _ in
                    context.triggerOnChangeHandler(id: watcherId)
                }
        } else {
            content
                .onChange(of: triggerValue) { _ in
                    context.triggerOnChangeHandler(id: watcherId)
                }
        }
    }
}
