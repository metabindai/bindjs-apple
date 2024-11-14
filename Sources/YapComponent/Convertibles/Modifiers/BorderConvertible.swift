import SwiftUI

struct BorderConvertible: ComponentConvertible {
    
    var color: ColorConvertible?
    var gradient: LinearGradientConvertible?
    var material: MaterialConvertible?
    var width: Double = 1.0
    
    init(_ component: Component) {
        // Check if width is explicitly provided, else default to 1.0
        if let width = component.props["width"] as? Double {
            self.width = width
        } else {
            self.width = 1.0
        }

        // Handle the ergonomic single `value` input case first
        if let color = component.props["value"] as? ColorConvertible {
            self.color = color
        } else if let gradient = component.props["value"] as? LinearGradientConvertible {
            self.gradient = gradient
        } else if let material = component.props["value"] as? MaterialConvertible {
            self.material = material
        } else if let width = component.props["value"] as? Double {
            self.width = width
            self.color = .primary
        }

        // If separate style key exists, it overrides value for finer control
        if let color = component.props["style"] as? ColorConvertible {
            self.color = color
        } else if let gradient = component.props["style"] as? LinearGradientConvertible {
            self.gradient = gradient
        } else if let material = component.props["style"] as? MaterialConvertible {
            self.material = material
        }

        // If no specific color, gradient, or material is given, default to primary color
        if self.color == nil && self.gradient == nil && self.material == nil {
            self.color = .primary
        }
    }
    
    var component: Component {
        var props: [String: any AST] = [:]

        // Include width only if it's different from the default value
        if width != 1.0 {
            props["width"] = width
        }

        // Add style properties based on what’s set in BorderConvertible
        if let color = color {
            props["style"] = color
        } else if let gradient = gradient {
            props["style"] = gradient
        } else if let material = material {
            props["style"] = material
        }

        return Component(type: Self.componentName, props: props)
    }
}

extension BorderConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let color = color {
            content.border(color.swiftUI, width: width)
        } else if let gradient = gradient {
            content.border(gradient.swiftUI, width: width)
        } else if let material = material {
            content.border(material.swiftUI, width: width)
        } else {
            content
        }
    }
}
