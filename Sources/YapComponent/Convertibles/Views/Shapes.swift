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

struct TriangleConvertible: ComponentConvertible {
    init(_ component: Component) {}
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension TriangleConvertible: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
    }
}

struct PolygonConvertible: ComponentConvertible {
    let sides: Int
    
    init(_ component: Component) {
        sides = Int(component.decode("sides") ?? component.decode("value") ?? 3)
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "sides": Double(sides)
            ]
        )
    }
}

extension PolygonConvertible: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let sides = min(max(3, sides), 100)
        
        // Start at π/2 (top center) and adjust for odd/even number of sides
        let startAngle: CGFloat = .pi / 2
        let angleOffset: CGFloat = sides % 2 == 0 ? 0 : .pi / CGFloat(sides)
        
        let points = stride(from: 0, to: CGFloat(sides) * 2 * .pi, by: .pi * 2 / CGFloat(sides))
            .map { angle in
                let adjustedAngle = angle + startAngle + angleOffset
                return CGPoint(
                    x: center.x + cos(adjustedAngle) * radius,
                    y: center.y + sin(adjustedAngle) * radius
                )
            }
        
        return Path { path in
            path.addLines(points)
            path.closeSubpath()
        }
    }
}
