import SwiftUI

public enum ButtonStyleComponent: @preconcurrency RawRepresentable, ComponentConvertible {
    case plain
    case borderedProminent
    case borderless
    case bordered
    case link
    case custom(String)
    
    public init(_ component: Component) {
        self = ButtonStyleComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .plain
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
    
    public var rawValue: String {
        switch self {
        case .plain: return "plain"
        case .borderedProminent: return "borderedProminent"
        case .borderless: return "borderless"
        case .bordered: return "bordered"
        case .link: return "link"
        case .custom(let value): return value
        }
    }
    
    public nonisolated init?(rawValue: RawValue) {
        switch rawValue {
        case "plain": self = .plain
        case "borderedProminent": self = .borderedProminent
        case "borderless": self = .borderless
        case "bordered": self = .bordered
        case "link": self = .link
        default: self = .custom(rawValue)
        }
    }
}

extension ButtonStyleComponent: ViewModifier {
    
    public func body(content: Content) -> some View {
        switch self {
        case .plain:
            content.buttonStyle(.plain)
        case .borderedProminent:
            content.buttonStyle(.borderedProminent)
        case .borderless:
            content.buttonStyle(.borderless)
        case .bordered:
            content.buttonStyle(.bordered)
        case .link:
            content
        case .custom(let name):
            content
                .buttonStyle(ComponentButtonStyle(name: name))
        }
    }
}

