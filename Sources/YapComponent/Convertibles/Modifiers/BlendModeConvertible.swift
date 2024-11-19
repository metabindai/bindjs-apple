import SwiftUI

enum BlendModeConvertible: String, CaseIterable, ComponentConvertible {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge
    case colorBurn
    case softLight
    case hardLight
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity
    
    init(_ component: Component) {
        self = Self(rawValue: component.decode("value") ?? "") ?? .normal
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": rawValue
        ])
    }
}

extension BlendModeConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.blendMode(BlendMode(stringValue: rawValue))
    }
}

extension BlendMode {
    init(stringValue: String) {
        switch stringValue {
        case "normal":
            self = .normal
        case "multiply":
            self = .multiply
        case "screen":
            self = .screen
        case "overlay":
            self = .overlay
        case "darken":
            self = .darken
        case "lighten":
            self = .lighten
        case "colorDodge":
            self = .colorDodge
        case "colorBurn":
            self = .colorBurn
        case "softLight":
            self = .softLight
        case "hardLight":
            self = .hardLight
        case "difference":
            self = .difference
        case "exclusion":
            self = .exclusion
        case "hue":
            self = .hue
        case "saturation":
            self = .saturation
        case "color":
            self = .color
        case "luminosity":
            self = .luminosity
        default:
            self = .normal
        }
    }
}
