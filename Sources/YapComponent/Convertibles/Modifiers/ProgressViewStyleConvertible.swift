import SwiftUI


enum ProgressViewStyleConvertible: ComponentConvertible {
    
    case circular
    case linear
    case custom(String)
    
    init(_ component: Component) {
        if let value: String = component.decode("value") {
            switch value {
            case "circular": self = .circular
            case "linear": self = .linear
            default: self = .custom(value)
            }
        } else {
            self = .linear
        }
    }
    
    var component: Component {
        let value: String = switch self {
        case .circular: "circular"
        case .linear: "linear"
        case .custom(let value): value
        }
        return Component(type: Self.componentName, props: ["value": value])
    }
}

extension ProgressViewStyleConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        switch self {
        case .circular:
            content.progressViewStyle(CircularProgressViewStyle())
        case .linear:
            content.progressViewStyle(LinearProgressViewStyle())
        case .custom(let value):
            content.progressViewStyle(ComponentProgressViewStyle(name: value))
        }
    }
}

