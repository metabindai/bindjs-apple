import SwiftUI

struct BackgroundConvertible: ComponentConvertible {
    let background: AST?
    
    init(_ component: Component) {
        background = component.props["value"]
    }
    
    var component: Component {
        if let background = background {
            return Component(type: Self.componentName, props: ["value": background])
        } else {
            return Component(type: Self.componentName, props: [:])
        }
    }
}

extension BackgroundConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let background {
            content.background(ComponentView(background))
        } else {
            content
        }
    }
}
