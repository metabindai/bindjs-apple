import SwiftUI

public enum MaterialComponent: String {
    case regular
    case ultraThin
    case thin
    case thick
    case ultraThick
}

extension MaterialComponent: ComponentConvertible {
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
    
    public init(_ component: Component) {
        self = MaterialComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .regular
    }
}

extension MaterialComponent {
    var swiftUI: Material {
        switch self {
        case .regular: .regular
        case .ultraThin: .ultraThin
        case .thin: .thin
        case .thick: .thick
        case .ultraThick: .ultraThick
        }
    }
}
