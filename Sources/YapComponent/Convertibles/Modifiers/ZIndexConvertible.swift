import SwiftUI

struct ZIndexConvertible: ComponentConvertible {
    let value: Double
    
    init(_ component: Component) {
        value = component.decode("value") ?? 0
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

extension ZIndexConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.zIndex(value)
    }
}
