import SwiftUI

public enum MaterialConvertible: String, ComponentConvertible {
    case regular
    case ultraThin
    case thin
    case thick
    case ultraThick
    
    init(_ component: Component) {
        self = MaterialConvertible(rawValue: component.decode("value") ?? "regular") ?? .regular
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": rawValue
        ])
    }
}

extension MaterialConvertible: View {
    var swiftUI: Material {
        switch self {
        case .regular:
            return .regular
        case .ultraThin:
            return .ultraThin
        case .thin:
            return .thin
        case .thick:
            return .thick
        case .ultraThick:
            return .ultraThick
        }
    }
    
    public var body: some View {
        Rectangle()
            .foregroundStyle(swiftUI)
    }
}
