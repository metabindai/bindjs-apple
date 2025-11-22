import SwiftUI

public struct TextFieldComponent: Component {
    public static var directiveName: String = "TextField"

    @EnvironmentObject private var context: BindJSContext

    public var placeholder: String
    public var currentValueId: String?
    public var setterId: String?
    public var environmentId: String
}

extension TextFieldComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        placeholder = directive["placeholder"] ?? ""
        currentValueId = directive["currentValueId"]
        setterId = directive["setterId"]
        environmentId = directive["environmentId"] ?? ""
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitTextField(self)
    }
}

extension TextFieldComponent: View {
    public var body: some View {
        TextField(placeholder, text: Binding(
            get: {
                context.restoreEnvironment(id: environmentId)
                return context.restoreTextFieldValue(id: currentValueId ?? "") ?? ""
            },
            set: { newValue in
                context.restoreEnvironment(id: environmentId)
                if let setterId = setterId {
                    context.callTextFieldSetter(id: setterId, value: newValue)
                }
            }
        ))
    }
}
