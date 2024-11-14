import SwiftUI

struct ItalicConvertible: ComponentConvertible {
    var isActive: Bool = true
    
    init(_ component: Component) {
        isActive = component.decode("value") ?? true
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": isActive
        ])
    }
}

extension ItalicConvertible: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.italic(isActive)
        } else {
            content
        }
    }
}
