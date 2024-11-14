import SwiftUI

struct OpacityConvertible: ComponentConvertible {
    let value: Double
    
    init(_ component: Component) {
        value = component.decode("value") ?? 1
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "value": value
            ]
        )
    }
}

extension OpacityConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.opacity(value)
    }
}
