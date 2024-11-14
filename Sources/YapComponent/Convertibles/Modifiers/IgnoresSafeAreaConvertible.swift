import SwiftUI

struct IgnoresSafeAreaConvertible: ComponentConvertible {
    
    let edges: String
    
    init(_ component: Component) {
        edges = component.decode("value") ?? "all"
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "value": edges
            ]
        )
    }
}

extension IgnoresSafeAreaConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.ignoresSafeArea(edges: .init(stringValue: edges))
    }
}

extension Edge.Set {
    init(stringValue: String) {
        switch stringValue {
        case "all":
            self = .all
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "horizontal":
            self = .horizontal
        case "vertical":
            self = .vertical
        default:
            self = .all
        }
    }
}
