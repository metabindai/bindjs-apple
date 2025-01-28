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
        sides = Int(min(100, component.decode("sides") ?? component.decode("value") ?? 3))
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

struct UnevenRoundedRectangleConvertible: ComponentConvertible {
    let topLeadingRadius: Double
    let topTrailingRadius: Double
    let bottomLeadingRadius: Double
    let bottomTrailingRadius: Double
    
    init(_ component: Component) {
        // If a single value is provided, use it for all corners
        if let value: Double = component.decode("value") {
            self.topLeadingRadius = value
            self.topTrailingRadius = value
            self.bottomLeadingRadius = value
            self.bottomTrailingRadius = value
        } else {
            // Otherwise use individual corner values with 0 as default
            self.topLeadingRadius = component.decode("topLeading") ?? 0
            self.topTrailingRadius = component.decode("topTrailing") ?? 0
            self.bottomLeadingRadius = component.decode("bottomLeading") ?? 0
            self.bottomTrailingRadius = component.decode("bottomTrailing") ?? 0
        }
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "topLeading": topLeadingRadius,
            "topTrailing": topTrailingRadius,
            "bottomLeading": bottomLeadingRadius,
            "bottomTrailing": bottomTrailingRadius
        ])
    }
}

extension UnevenRoundedRectangleConvertible: View {
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRadius,
                bottomLeadingRadius: bottomLeadingRadius,
                bottomTrailingRadius: bottomTrailingRadius,
                topTrailingRadius: topTrailingRadius,
                style: .continuous
            )
        } else {
            // Fallback for older versions - use regular RoundedRectangle with average radius
            let averageRadius = (topLeadingRadius + topTrailingRadius + bottomLeadingRadius + bottomTrailingRadius) / 4
            RoundedRectangle(cornerRadius: averageRadius, style: .continuous)
        }
    }
}
