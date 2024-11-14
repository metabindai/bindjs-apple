import SwiftUI

enum ButtonStyleConvertible: ComponentConvertible {
    
    case plain
    case borderedProminent
    case bordered
    case borderless
    case link
    case custom(String)
    
    init(_ component: Component) {
        if let value: String = component.decode("value") {
            switch value {
            case "plain": self = .plain
            case "borderedProminent": self = .borderedProminent
            case "bordered": self = .bordered
            case "borderless": self = .borderless
            case "link": self = .link
            default: self = .custom(value)
            }
        } else {
            self = .plain
        }
    }
    
    var component: Component {
        let value: String = switch self {
        case .plain: "plain"
        case .borderedProminent: "borderedProminent"
        case .bordered: "bordered"
        case .borderless: "borderless"
        case .link: "link"
        case .custom(let value): value
        }
        return Component(type: Self.componentName, props: ["value": value])
    }
}

extension ButtonStyleConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        switch self {
        case .plain:
            content.buttonStyle(PlainButtonStyle())
        case .borderedProminent:
            content.buttonStyle(BorderedButtonStyle())
        case .bordered:
            content.buttonStyle(BorderedButtonStyle())
        case .borderless:
            content.buttonStyle(BorderlessButtonStyle())
        case .link:
            #if os(macOS)
            content.buttonStyle(LinkButtonStyle())
            #else
            content.buttonStyle(PlainButtonStyle()) 
            #endif
        case .custom(let value):
            content.buttonStyle(ComponentButtonStyle(name: value))
        }
    }
}
