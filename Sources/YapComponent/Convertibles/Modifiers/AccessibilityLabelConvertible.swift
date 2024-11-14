import SwiftUI

struct AccessibilityLabelConvertible: ComponentConvertible {
    let value: String?
    
    init(_ component: Component) {
        value = component.decode("value")
    }
    
    var component: Component {
        if let value = value {
            return Component(
                type: Self.componentName,
                props: [
                    "value": value
                ]
            )
        } else {
            return Component(
                type: Self.componentName,
                props: [:]
            )
        }
    }
}

extension AccessibilityLabelConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let value = value {
            content.accessibilityLabel(Text(value))
        } else {
            content
        }
    }
}
