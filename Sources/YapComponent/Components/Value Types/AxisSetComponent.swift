import SwiftUI

public enum AxisSetComponent: String {
    case horizontal
    case vertical
    case both
}

extension AxisSetComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = AxisSetComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .vertical
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
}

extension AxisSetComponent {
    var swiftUI: Axis.Set {
        switch self {
        case .vertical:
            return .vertical
        case .horizontal:
            return .horizontal
        case .both:
            return [.vertical, .horizontal]
        }
    }
}
