import SwiftUI

struct LinearGradientComponent: Component {
    static var directiveName: String = "LinearGradient"
    
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
}

extension LinearGradientComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        let colors = directive["colors"].compactMap(makeComponent).compactMap { $0 as? ColorComponent }.map(\.swiftUI)
        if colors.isEmpty {
            self.colors = [.white, .black]
        } else {
            self.colors = colors
        }
        startPoint = directive["startPoint"] ?? .top
        endPoint = directive["endPoint"] ?? .bottom
    }
}

extension LinearGradientComponent: View {
    var swiftUI: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    var body: some View {
        swiftUI
    }
}

struct AngularGradientComponent: Component {
    static var directiveName: String = "AngularGradient"
    
    let colors: [Color]
    let center: UnitPoint
    let startAngle: Angle
    let endAngle: Angle
}

extension AngularGradientComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        let colors = directive["colors"].compactMap(makeComponent).compactMap { $0 as? ColorComponent }.map(\.swiftUI)
        if colors.isEmpty {
            self.colors = [.white, .black]
        } else {
            self.colors = colors
        }
        center = directive["center"] ?? .center
        startAngle = Angle(degrees: directive["startAngle"] ?? 0)
        endAngle = Angle(degrees: directive["endAngle"] ?? 360)
    }
}

extension AngularGradientComponent: View {
    var swiftUI: AngularGradient {
        AngularGradient(
            colors: colors,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }
    
    var body: some View {
        swiftUI
    }
}

struct RadialGradientComponent: Component {
    static var directiveName: String = "RadialGradient"
    
    let colors: [Color]
    let center: UnitPoint
    let startRadius: CGFloat
    let endRadius: CGFloat
}

extension RadialGradientComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        let colors = directive["colors"].compactMap(makeComponent).compactMap { $0 as? ColorComponent }.map(\.swiftUI)
        if colors.isEmpty {
            self.colors = [.white, .black]
        } else {
            self.colors = colors
        }
        center = directive["center"] ?? .center
        startRadius = directive["startRadius"] ?? 0.0
        endRadius = directive["endRadius"] ?? 128.0
    }
}

extension RadialGradientComponent: View {
    var swiftUI: RadialGradient {
        RadialGradient(
            colors: colors,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
    
    var body: some View {
        swiftUI
    }
}

struct EllipticalGradientComponent: Component {
    static var directiveName: String = "EllipticalGradient"
    
    let colors: [Color]
    let center: UnitPoint
    let startRadiusFraction: CGFloat
    let endRadiusFraction: CGFloat
}

extension EllipticalGradientComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        let colors = directive["colors"].compactMap(makeComponent).compactMap { $0 as? ColorComponent }.map(\.swiftUI)
        if colors.isEmpty {
            self.colors = [.white, .black]
        } else {
            self.colors = colors
        }
        center = directive["center"] ?? .center
        startRadiusFraction = directive["startRadiusFraction"] ?? 0.0
        endRadiusFraction = directive["endRadiusFraction"] ?? 0.5
    }
}

extension EllipticalGradientComponent: View {
    var swiftUI: EllipticalGradient {
        EllipticalGradient(
            colors: colors,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }
    
    var body: some View {
        swiftUI
    }
}
