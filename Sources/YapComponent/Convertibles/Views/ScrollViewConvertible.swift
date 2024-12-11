import SwiftUI

struct ScrollViewConvertible: ComponentConvertible {
    let axes: String
    let showsIndicators: Bool
    let children: AST
    
    init(_ component: Component) {
        axes = component.decode("axis") ?? Axis.Set.vertical.stringValue
        showsIndicators = component.decode("showsIndicators") ?? true
        children = component.children
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "axis": axes,
            "showsIndicators": showsIndicators,
            "children": children
        ])
    }
}

extension ScrollViewConvertible: View {
    var body: some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            ScrollView(.init(stringValue: axes), showsIndicators: showsIndicators) {
                ComponentView(children)
            }
            .scrollClipDisabled()
        } else {
            ScrollView(.init(stringValue: axes), showsIndicators: showsIndicators) {
                ComponentView(children)
            }
        }
    }
}

extension Axis.Set {
    var stringValue: String {
        switch self {
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        case [.horizontal, .vertical]:
            return "both"
        default:
            return "vertical"
        }
    }
    
    init(stringValue: String) {
        switch stringValue {
        case "horizontal":
            self = .horizontal
        case "vertical":
            self = .vertical
        case "both":
            self = [.horizontal, .vertical]
        default:
            self = .vertical
        }
    }
}
