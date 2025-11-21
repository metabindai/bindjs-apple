import SwiftUI

public struct TextEditorComponent: Component {
    public static var directiveName: String = "TextEditor"

    @EnvironmentObject private var context: BindJSContext

    public var currentValueId: String?
    public var setterId: String?
    public var environmentId: String
}

extension TextEditorComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        currentValueId = directive["currentValueId"]
        setterId = directive["setterId"]
        environmentId = directive["environmentId"] ?? ""
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitTextEditor(self)
    }
}

extension TextEditorComponent: View {
    public var body: some View {
        TextEditor(text: Binding(
            get: {
                context.restoreEnvironment(id: environmentId)
                return context.restoreTextEditorValue(id: currentValueId ?? "") ?? ""
            },
            set: { newValue in
                context.restoreEnvironment(id: environmentId)
                if let setterId = setterId {
                    context.callTextEditorSetter(id: setterId, value: newValue)
                }
            }
        ))
    }
}
