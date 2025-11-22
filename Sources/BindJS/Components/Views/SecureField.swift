import SwiftUI

public struct SecureFieldComponent: Component {
    public static var directiveName: String = "SecureField"

    @EnvironmentObject private var context: BindJSContext

    public var placeholder: String
    public var currentValueId: String?
    public var setterId: String?
    public var environmentId: String
}

extension SecureFieldComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        placeholder = directive["placeholder"] ?? ""
        currentValueId = directive["currentValueId"]
        setterId = directive["setterId"]
        environmentId = directive["environmentId"] ?? ""
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitSecureField(self)
    }
}

extension SecureFieldComponent: View {
    public var body: some View {
        SecureField(placeholder, text: Binding(
            get: {
                context.restoreEnvironment(id: environmentId)
                return context.restoreSecureFieldValue(id: currentValueId ?? "") ?? ""
            },
            set: { newValue in
                context.restoreEnvironment(id: environmentId)
                if let setterId = setterId {
                    context.callSecureFieldSetter(id: setterId, value: newValue)
                }
            }
        ))
    }
}
