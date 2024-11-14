import SwiftUI

struct KerningConvertible: ComponentConvertible {
    var value: Double = 0.0
    
    init(_ component: Component) {
        value = component.decode("value") ?? 0.0
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": value
        ])
    }
}

extension KerningConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.kerning(value)
        } else {
            content
        }
    }
}
