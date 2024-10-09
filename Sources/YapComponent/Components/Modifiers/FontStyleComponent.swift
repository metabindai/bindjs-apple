import SwiftUI

public enum FontStyleComponent: String {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2
}

extension FontStyleComponent: ComponentConvertible {
    public init(_ component: Component) {
        self = FontStyleComponent(rawValue: component.props["rawValue"] as? String ?? "") ?? .body
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: ["rawValue": String(describing: self)])
    }
}

extension FontStyleComponent: ViewModifier {
    
    public func body(content: Content) -> some View {
        content.font(.system(swiftUI))
    }
    
    var swiftUI: Font.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .caption2:
            return .caption2
        }
    }
}
