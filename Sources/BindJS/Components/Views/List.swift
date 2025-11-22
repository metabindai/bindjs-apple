import SwiftUI

public struct ListComponent: Component {
    public static var directiveName: String = "List"

    @EnvironmentObject private var context: BindJSContext

    public var currentSelectionId: String?
    public var selectionSetterId: String?
    public var environmentId: String
    public var children: [Component]
}

extension ListComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        currentSelectionId = directive["currentSelectionId"]
        selectionSetterId = directive["selectionSetterId"]
        environmentId = directive["environmentId"] ?? ""
        children = directive.children.compactMap { makeComponent($0) }
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitList(self)
    }
}

extension ListComponent: View {
    public var body: some View {
        if currentSelectionId != nil && selectionSetterId != nil {
            // List with selection binding
            List(selection: Binding(
                get: {
                    context.restoreEnvironment(id: environmentId)
                    return context.restoreListSelection(id: currentSelectionId ?? "")
                },
                set: { newValue in
                    context.restoreEnvironment(id: environmentId)
                    if let selectionSetterId = selectionSetterId {
                        context.callListSelectionSetter(id: selectionSetterId, value: newValue)
                    }
                }
            )) {
                ForEach(children.indices, id: \.self) { index in
                    ComponentView(children[index])
                }
            }
        } else {
            // List without selection
            List {
                ForEach(children.indices, id: \.self) { index in
                    ComponentView(children[index])
                }
            }
        }
    }
}
