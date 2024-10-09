import SwiftUI

public enum VerticalAlignmentComponent: String {
    case top
    case center
    case bottom
    case firstTextBaseline
    case lastTextBaseline
}

extension VerticalAlignmentComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = VerticalAlignmentComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .center
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": rawValue])
    }
}

extension VerticalAlignmentComponent {
    var swiftUI: VerticalAlignment {
        switch self {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        case .firstTextBaseline:
            return .firstTextBaseline
        case .lastTextBaseline:
            return .lastTextBaseline
        }
    }
}
