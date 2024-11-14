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
