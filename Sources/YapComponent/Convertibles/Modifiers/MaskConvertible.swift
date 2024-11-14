import SwiftUI


struct MaskConvertible: ComponentConvertible {
    let mask: AST?
    
    init(_ component: Component) {
        mask = component.props["value"]
    }
    
    var component: Component {
        if let mask = mask {
            return Component(type: Self.componentName, props: ["value": mask])
        } else {
            return Component(type: Self.componentName, props: [:])
        }
    }
}

extension MaskConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let mask {
            content.mask(ComponentView(mask))
        } else {
            content
        }
    }
}
