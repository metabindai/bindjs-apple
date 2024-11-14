import SwiftUI

struct CircleConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension CircleConvertible: View {
    var body: some View {
        Circle()
    }
}

struct RectangleConvertible: ComponentConvertible {
    let cornerRadius: Double?
    
    static var roundedRectangleName: String {
        "roundedrectangle"
    }
    
    init(_ component: Component) {
        cornerRadius = component.decode("cornerRadius") ?? component.decode("value")
    }
    
    var component: Component {
        if let cornerRadius = cornerRadius {
            return Component(
                type: Self.componentName,
                props: [
                    "cornerRadius": cornerRadius
                ]
            )
        } else {
            return Component(
                type: Self.componentName
            )
        }
    }
}

extension RectangleConvertible: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius ?? 0, style: .continuous)
    }
}

struct CapsuleConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension CapsuleConvertible: View {
    var body: some View {
        Capsule()
    }
}

struct EllipseConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension EllipseConvertible: View {
    var body: some View {
        Ellipse()
    }
}
