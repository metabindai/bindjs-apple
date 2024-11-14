import SwiftUI

struct ForegroundStyleConvertible: ComponentConvertible {
    var color: ColorConvertible?
    var gradient: LinearGradientConvertible?
    var material: MaterialConvertible?
    
    init(_ component: Component) {
        if let color = component.props["value"] as? ColorConvertible {
            self.color = color
        } else if let gradient = component.props["value"] as? LinearGradientConvertible {
            self.gradient = gradient
        } else if let material = component.props["value"] as? MaterialConvertible {
            self.material = material
        }
    }
    
    var component: Component {
        if let color = color {
            return Component(
                type: Self.componentName,
                props: [
                    "value": color.component
                ]
            )
        } else if let gradient = gradient {
            return Component(
                type: Self.componentName,
                props: [
                    "value": gradient.component
                ]
            )
        } else if let material = material {
            return Component(
                type: Self.componentName,
                props: [
                    "value": material.component
                ]
            )
        } else {
            return Component(
                type: Self.componentName
            )
        }
    }
}

extension ForegroundStyleConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let color = color {
            content.foregroundStyle(color.swiftUI)
        } else if let gradient = gradient {
            content.foregroundStyle(gradient.swiftUI)
        } else if let material = material {
            content.foregroundStyle(material.swiftUI)
        } else {
            content
        }
    }
}
