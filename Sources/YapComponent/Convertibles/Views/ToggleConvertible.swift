import SwiftUI

struct ToggleConvertible: ComponentConvertible {
    let isOn: Bool
    let label: AST
    
    init(_ component: Component) {
        isOn = component.decode("isOn") ?? component.decode("value") ?? false
        label = component.decode("label") ?? EmptyComponent()
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "isOn": isOn
            ]
        )
    }
}

extension ToggleConvertible: View {
    var body: some View {
        Toggle(isOn: .constant(isOn)) {
            ComponentView(label)
        }
    }
}
