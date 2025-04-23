import SwiftUI

struct CircleComponent: Component {
    static var directiveName: String = "Circle"
}

extension CircleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension CircleComponent: View {
    var body: some View {
        Circle()
    }
}

struct EllipseComponent: Component {
    static var directiveName: String = "Ellipse"
}

extension EllipseComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension EllipseComponent: View {
    var body: some View {
        Ellipse()
    }
}

struct RectangleComponent: Component {
    static var directiveName: String = "Rectangle"
}

extension RectangleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension RectangleComponent: View {
    var body: some View {
        Rectangle()
    }
}

struct RoundedRectangleComponent: Component {
    static var directiveName: String = "RoundedRectangle"
    
    let cornerRadius: CGFloat
}

extension RoundedRectangleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        cornerRadius = directive["cornerRadius"] ?? 10
    }
}

extension RoundedRectangleComponent: View {
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
}

struct CapsuleComponent: Component {
    static var directiveName: String = "Capsule"
}

extension CapsuleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension CapsuleComponent: View {
    var body: some View {
        Capsule()
    }
}
