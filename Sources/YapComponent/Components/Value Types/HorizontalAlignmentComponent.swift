import SwiftUI

public enum HorizontalAlignmentComponent: String {
    case leading
    case center
    case trailing
}

extension HorizontalAlignmentComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = HorizontalAlignmentComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .center
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
}

extension HorizontalAlignmentComponent {
    var swiftUI: HorizontalAlignment {
        switch self {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
