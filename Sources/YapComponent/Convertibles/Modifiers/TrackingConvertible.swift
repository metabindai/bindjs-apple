import SwiftUI

struct TrackingConvertible: ComponentConvertible {
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

extension TrackingConvertible: ViewModifier {
    
    func body(content: Self.Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.tracking(value)
        } else {
            content
        }
    }
}
