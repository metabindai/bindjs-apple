import SwiftUI

enum LabelStyleConvertible: ComponentConvertible {
    
    case iconOnly
    case titleAndIcon
    case titleOnly
    case automatic
    case custom(String)
    
    init(_ component: Component) {
        if let value: String = component.decode("value") {
            switch value {
            case "iconOnly": self = .iconOnly
            case "titleAndIcon": self = .titleAndIcon
            case "titleOnly": self = .titleOnly
            case "automatic": self = .automatic
            default: self = .custom(value)
            }
        } else {
            self = .automatic
        }
    }
    
    var component: Component {
        let value: String = switch self {
        case .iconOnly: "iconOnly"
        case .titleAndIcon: "titleAndIcon"
        case .titleOnly: "titleOnly"
        case .automatic: "automatic"
        case .custom(let value): value
        }
        return Component(type: Self.componentName, props: ["value": value])
    }
}

extension LabelStyleConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        switch self {
        case .iconOnly:
            content.labelStyle(IconOnlyLabelStyle())
        case .titleAndIcon:
            content.labelStyle(TitleAndIconLabelStyle())
        case .titleOnly:
            content.labelStyle(TitleOnlyLabelStyle())
        case .automatic:
            content.labelStyle(.automatic)
        case .custom(let value):
            content.labelStyle(ComponentLabelStyle(name: value))
        }
    }
}
