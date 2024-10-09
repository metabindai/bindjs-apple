import SwiftUI

public enum ContentModeComponent: String {
    case fit
    case fill
}

extension ContentModeComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = ContentModeComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .fit
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
}

extension ContentModeComponent {
    var swiftUI: ContentMode {
        switch self {
        case .fit:
            return .fit
        case .fill:
            return .fill
        }
    }
}
