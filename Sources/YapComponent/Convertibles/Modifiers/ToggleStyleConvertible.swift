import SwiftUI

enum ToggleStyleConvertible: ComponentConvertible {
    
    case checkbox
    case `switch`
    case button
    case `default`
    case custom(String)
    
    init(_ component: Component) {
        if let value: String = component.decode("value") {
            switch value {
            case "checkbox":
                self = .checkbox
            case "switch":
                self = .switch
            case "button":
                self = .button
            case "default":
                self = .default
            default:
                self = .custom(value)
            }
        } else {
            self = .default
        }
    }
    
    var component: Component {
        let value: String = switch self {
        case .checkbox: "checkbox"
        case .switch: "switch"
        case .button: "button"
        case .default: "default"
        case .custom(let value): value
        }
        return Component(type: Self.componentName, props: ["value": value])
    }
}

extension ToggleStyleConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        switch self {
        case .checkbox:
            #if os(macOS)
            content.toggleStyle(.checkbox)
            #else
            content
            #endif
        case .switch: content.toggleStyle(.switch)
        case .button: content.toggleStyle(.button)
        case .default: content.toggleStyle(DefaultToggleStyle())
            case .custom(let value): content.toggleStyle(ComponentToggleStyle(name: value))
        }
    }
}
