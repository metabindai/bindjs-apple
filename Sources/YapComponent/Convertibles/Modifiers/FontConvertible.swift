import SwiftUI

struct FontConvertible: ComponentConvertible {
    enum Storage {
        case size(Double)
        case name(String)
    }
    
    static var fontSizeName: String {
        "fontsize"
    }
    
    let storage: Storage?
    
    init(_ component: Component) {
        if let value: Double = component.decode("value") {
            storage = .size(value)
        } else if let name: String = component.decode("value") {
            storage = .name(name)
        } else {
            storage = nil
        }
    }
    
    var component: Component {
        if let storage = storage {
            switch storage {
            case .size(let size):
                return Component(type: Self.componentName, props: ["value": size])
            case .name(let name):
                return Component(type: Self.componentName, props: ["value": name])
            }
        } else {
            return Component(type: Self.componentName)
        }
    }
}

extension FontConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        if let storage = storage {
            switch storage {
            case .size(let size):
                return content.font(.system(size: CGFloat(size)))
            case .name(let name):
                let font: Font = switch name {
                case "body": .body
                case "callout": .callout
                case "caption": .caption
                case "footnote": .footnote
                case "headline": .headline
                case "largeTitle": .largeTitle
                case "subheadline": .subheadline
                case "title": .title
                case "title2": .title2
                case "title3": .title3
                default: .body
                }
                return content.font(font)
            }
        } else {
            return content.font(nil)
        }
    }
}
