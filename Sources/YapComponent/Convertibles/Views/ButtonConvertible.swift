import SwiftUI

struct ButtonConvertible: ComponentConvertible {
    let action: String
    let label: AST
    let environmentId: String
    
    init(_ component: Component) {
        self.action = component.decode("action") ?? ""
        self.label = component.props["label"] ?? component.props["value"] ?? EmptyComponent()
        self.environmentId = component.decode("environmentId") ?? ""
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "action": action,
            "label": label
        ])
    }
}

extension ButtonConvertible: View {
    var body: some View {
        Button(action: {
            print("do button action: \(action)")
        }) {
            ComponentView(label)
        }
        .transformEnvironment(\.componentRuntime) { runtime in
            runtime.restoreEnvironment(id: environmentId)
        }
    }
}
