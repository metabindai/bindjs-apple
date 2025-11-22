import SwiftUI

public struct ToggleComponent: Component {
    public static var directiveName: String = "Toggle"

    @EnvironmentObject private var context: BindJSContext

    public var label: String
    public var currentValueId: String?
    public var setterId: String?
    public var environmentId: String
}

extension ToggleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        label = directive["label"] ?? ""
        currentValueId = directive["currentValueId"]
        setterId = directive["setterId"]
        environmentId = directive["environmentId"] ?? ""
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitToggle(self)
    }
}

extension ToggleComponent: View {
    public var body: some View {
        Toggle(label, isOn: Binding(
            get: {
                context.restoreEnvironment(id: environmentId)
                return context.restoreToggleValue(id: currentValueId ?? "") ?? false
            },
            set: { newValue in
                context.restoreEnvironment(id: environmentId)
                if let setterId = setterId {
                    context.callToggleSetter(id: setterId, value: newValue)
                }
            }
        ))
    }
}
