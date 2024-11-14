import SwiftUI

enum FontDesignConvertible: String {
    case `default`
    case serif
    case rounded
    case monospaced
}

extension FontDesignConvertible: ComponentConvertible {
    init(_ component: Component) {
        self = FontDesignConvertible(rawValue: component.decode("value") ?? "default") ?? .default
    }
    
    public var component: Component {
        Component(type: Self.componentName, props: [
            "value": rawValue
        ])
    }
}

extension FontDesignConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        if #available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *) {
            content.fontDesign(swiftUI)
        } else {
            content
        }
    }
    
    var swiftUI: Font.Design {
        switch self {
        case .default:
            return .default
        case .serif:
            return .serif
        case .rounded:
            return .rounded
        case .monospaced:
            return .monospaced
        }
    }
}
