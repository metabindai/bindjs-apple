import SwiftUI

enum ShapeStyle {
    case fill(Component)
    case stroke(Component, lineWidth: CGFloat)
}

protocol ShapeComponent: Component {
    var style: ShapeStyle? { get set }
}

struct CircleComponent: ShapeComponent {
    static var directiveName: String = "Circle"
    
    var style: ShapeStyle?
}

extension CircleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let fill = directive["fill"].flatMap(makeComponent) {
            style = .fill(fill)
        } else if let stroke = directive["stroke"].flatMap(makeComponent) {
            let lineWidth: CGFloat = directive["lineWidth"] ?? 1
            style = .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension CircleComponent: View {
    var body: some View {
        switch style {
        case .none: Circle()
        case .fill(let fill):
            Circle().fill(fill)
        case .stroke(let stroke, let lineWidth):
            Circle().stroke(stroke, lineWidth: lineWidth)
        }
    }
}

struct EllipseComponent: ShapeComponent {
    static var directiveName: String = "Ellipse"
    
    var style: ShapeStyle?
}

extension EllipseComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let fill = directive["fill"].flatMap(makeComponent) {
            style = .fill(fill)
        } else if let stroke = directive["stroke"].flatMap(makeComponent) {
            let lineWidth: CGFloat = directive["lineWidth"] ?? 1
            style = .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension EllipseComponent: View {
    var body: some View {
        switch style {
        case .none: Ellipse()
        case .fill(let fill):
            Ellipse().fill(fill)
        case .stroke(let stroke, let lineWidth):
            Ellipse().stroke(stroke, lineWidth: lineWidth)
        }
    }
}

struct RectangleComponent: ShapeComponent {
    static var directiveName: String = "Rectangle"
    
    var style: ShapeStyle?
}

extension RectangleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let fill = directive["fill"].flatMap(makeComponent) {
            style = .fill(fill)
        } else if let stroke = directive["stroke"].flatMap(makeComponent) {
            let lineWidth: CGFloat = directive["lineWidth"] ?? 1
            style = .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension RectangleComponent: View {
    var body: some View {
        switch style {
        case .none: Rectangle()
        case .fill(let fill):
            Rectangle().fill(fill)
        case .stroke(let stroke, let lineWidth):
            Rectangle().stroke(stroke, lineWidth: lineWidth)
        }
    }
}

struct RoundedRectangleComponent: ShapeComponent {
    static var directiveName: String = "RoundedRectangle"
    
    let cornerRadius: CGFloat
    var style: ShapeStyle?
}

extension RoundedRectangleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        cornerRadius = directive["cornerRadius"] ?? 10
        
        if let fill = directive["fill"].flatMap(makeComponent) {
            style = .fill(fill)
        } else if let stroke = directive["stroke"].flatMap(makeComponent) {
            let lineWidth: CGFloat = directive["lineWidth"] ?? 1
            style = .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension RoundedRectangleComponent: View {
    var body: some View {
        switch style {
        case .none: RoundedRectangle(cornerRadius: cornerRadius)
        case .fill(let fill):
            RoundedRectangle(cornerRadius: cornerRadius).fill(fill)
        case .stroke(let stroke, let lineWidth):
            RoundedRectangle(cornerRadius: cornerRadius).stroke(stroke, lineWidth: lineWidth)
        }
    }
}

struct CapsuleComponent: ShapeComponent {
    static var directiveName: String = "Capsule"
    
    var style: ShapeStyle?
}

extension CapsuleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let fill = directive["fill"].flatMap(makeComponent) {
            style = .fill(fill)
        } else if let stroke = directive["stroke"].flatMap(makeComponent) {
            let lineWidth: CGFloat = directive["lineWidth"] ?? 1
            style = .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension CapsuleComponent: View {
    var body: some View {
        switch style {
        case .none: Capsule()
        case .fill(let fill):
            Capsule().fill(fill)
        case .stroke(let stroke, let lineWidth):
            Capsule().stroke(stroke, lineWidth: lineWidth)
        }
    }
}

extension Shape {
    func fill(_ style: Component) -> some View {
        modifier(ForegroundStyleComponent(style: style))
    }

    @ViewBuilder
    func stroke(_ style: Component, lineWidth: CGFloat) -> some View {
        switch style {
        case let color as ColorComponent:
            self.stroke(color.swiftUI, lineWidth: lineWidth)
        case let linearGradient as LinearGradientComponent:
            self.stroke(linearGradient.swiftUI, lineWidth: lineWidth)
        case let angularGradient as AngularGradientComponent:
            self.stroke(angularGradient.swiftUI, lineWidth: lineWidth)
        case let radialGradient as RadialGradientComponent:
            self.stroke(radialGradient.swiftUI, lineWidth: lineWidth)
        case let ellipticalGradient as EllipticalGradientComponent:
            self.stroke(ellipticalGradient.swiftUI, lineWidth: lineWidth)
        case let material as MaterialComponent:
            self.stroke(material.swiftUI, lineWidth: lineWidth)
        default:
            self.stroke(Color.primary, lineWidth: lineWidth)
        }
    }
}
