import SwiftUI

public enum FontWeightComponent: String {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
}

extension FontWeightComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = FontWeightComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .regular
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": String(describing: self)])
    }
}

extension FontWeightComponent: ViewModifier {
    
    public func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.fontWeight(swiftUI)
        } else {
            content
        }
    }
    
    var swiftUI: Font.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }
}
