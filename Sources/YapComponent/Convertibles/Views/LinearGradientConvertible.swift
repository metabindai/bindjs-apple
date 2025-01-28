import SwiftUI

public struct LinearGradientConvertible: ComponentConvertible {
    let startPoint: String
    let endPoint: String
    var colors: [ColorConvertible]
    
    init(_ component: Component) {
        self.startPoint = component.decode("startPoint") ?? "top"
        self.endPoint = component.decode("endPoint") ?? "bottom"
        let rawColors: [AST] = component.decode("colors") ?? []
        colors = rawColors.compactMap { $0 as? ColorConvertible }
        if colors.isEmpty {
            colors = [ColorConvertible.white, ColorConvertible.black]
        }
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "startPoint": startPoint,
            "endPoint": endPoint,
            "colors": colors.map { $0 as AST }
        ])
    }
}

extension UnitPoint {
    init(stringValue: String) {
        switch stringValue {
        case "center":
            self = .center
        case "zero":
            self = .zero
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "topLeading":
            self = .topLeading
        case "topTrailing":
            self = .topTrailing
        case "bottomLeading":
            self = .bottomLeading
        case "bottomTrailing":
            self = .bottomTrailing
        default:
            self = .top
        }
    }
}

extension LinearGradientConvertible: View {
    
    var swiftUI: LinearGradient {
        LinearGradient(
            colors: colors.map(\.swiftUI),
            startPoint: UnitPoint(stringValue: startPoint),
            endPoint: UnitPoint(stringValue: endPoint)
        )
    }
    
    public var body: some View {
        swiftUI
    }
}

public struct AngularGradientConvertible: ComponentConvertible {
    let center: String
    let startAngle: Double
    let endAngle: Double
    var colors: [ColorConvertible]
    
    init(_ component: Component) {
        self.center = component.decode("center") ?? "center"
        self.startAngle = component.decode("startAngle") ?? 0
        self.endAngle = component.decode("endAngle") ?? 360
        let rawColors: [AST] = component.decode("colors") ?? []
        colors = rawColors.compactMap { $0 as? ColorConvertible }
        if colors.isEmpty {
            colors = [ColorConvertible.white, ColorConvertible.black]
        }
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "center": center,
            "startAngle": startAngle,
            "endAngle": endAngle,
            "colors": colors.map { $0 as AST }
        ])
    }
}

extension AngularGradientConvertible: View {
    var swiftUI: AngularGradient {
        AngularGradient(
            colors: colors.map(\.swiftUI),
            center: UnitPoint(stringValue: center),
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle)
        )
    }
    
    public var body: some View {
        swiftUI
    }
}

public struct EllipticalGradientConvertible: ComponentConvertible {
    let center: String
    let startRadiusFraction: Double
    let endRadiusFraction: Double
    var colors: [ColorConvertible]
    
    init(_ component: Component) {
        self.center = component.decode("center") ?? "center"
        self.startRadiusFraction = component.decode("startRadiusFraction") ?? 0
        self.endRadiusFraction = component.decode("endRadiusFraction") ?? 0.5
        let rawColors: [AST] = component.decode("colors") ?? []
        colors = rawColors.compactMap { $0 as? ColorConvertible }
        if colors.isEmpty {
            colors = [ColorConvertible.white, ColorConvertible.black]
        }
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "center": center,
            "startRadiusFraction": startRadiusFraction,
            "endRadiusFraction": endRadiusFraction,
            "colors": colors.map { $0 as AST }
        ])
    }
}

extension EllipticalGradientConvertible: View {
    var swiftUI: EllipticalGradient {
        EllipticalGradient(
            colors: colors.map(\.swiftUI),
            center: UnitPoint(stringValue: center),
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }
    
    public var body: some View {
        swiftUI
    }
}
