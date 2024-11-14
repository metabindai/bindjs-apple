import SwiftUI

struct HiddenConvertible: ComponentConvertible {
    var isHidden: Bool
    
    init(_ component: Component) {
        isHidden = component.decode("value") ?? false
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": isHidden
        ])
    }
}

extension HiddenConvertible: ViewModifier {
        
    public func body(content: Content) -> some View {
        if isHidden {
            content.hidden()
        } else {
            content
        }
    }
}
