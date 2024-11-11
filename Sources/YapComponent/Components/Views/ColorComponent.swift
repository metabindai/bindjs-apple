import SwiftUI

public struct ColorComponent: ComponentConvertible {
    public enum Storage {
        case rgba(red: Double, green: Double, blue: Double, opacity: Double)
        case semantic(name: String)
    }
    
    public var storage: Storage
    
    public init(red: Double = 0.0, green: Double = 0.0, blue: Double = 0.0, opacity: Double = 1.0) {
        self.storage = .rgba(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public init(_ component: Component) {
        if let name = component.props["rawValue"] as? String {
            self.storage = .semantic(name: name)
        } else if let red = component.decode("red", as: Double.self),
                  let green = component.decode("green", as: Double.self),
                  let blue = component.decode("blue", as: Double.self),
                  case let opacity = component.decode("opacity", as: Double.self) ?? 1.0
        {
            self.storage = .rgba(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            self.storage = .semantic(name: "primary")
        }
    }
    
    public var component: Component {
        switch storage {
        case .rgba(red: let red, green: let green, blue: let blue, opacity: let opacity):
            return Component(type: Self.componentName, props: [
                "red": red,
                "green": green,
                "blue": blue,
                "opacity": opacity
            ])
        case .semantic(let name):
            return Component(type: Self.componentName, props: ["rawValue": name])
        }
    }
}

public extension ColorComponent {
    static let clear = ColorComponent(red: 0, green: 0, blue: 0, opacity: 0)
    static let red = ColorComponent(red: 255/255, green: 59/255, blue: 48/255, opacity: 1)
    static let orange = ColorComponent(red: 255/255, green: 149/255, blue: 0/255, opacity: 1)
    static let yellow = ColorComponent(red: 255/255, green: 204/255, blue: 0/255, opacity: 1)
    static let green = ColorComponent(red: 52/255, green: 199/255, blue: 89/255, opacity: 1)
    static let mint = ColorComponent(red: 0/255, green: 199/255, blue: 190/255, opacity: 1)
    static let teal = ColorComponent(red: 48/255, green: 176/255, blue: 199/255, opacity: 1)
    static let cyan = ColorComponent(red: 50/255, green: 173/255, blue: 230/255, opacity: 1)
    static let blue = ColorComponent(red: 0/255, green: 122/255, blue: 255/255, opacity: 1)
    static let navy = ColorComponent(red: 0/255, green: 0/255, blue: 128/255, opacity: 1)
    static let indigo = ColorComponent(red: 88/255, green: 86/255, blue: 214/255, opacity: 1)
    static let purple = ColorComponent(red: 175/255, green: 82/255, blue: 222/255, opacity: 1)
    static let pink = ColorComponent(red: 255/255, green: 45/255, blue: 85/255, opacity: 1)
    static let brown = ColorComponent(red: 162/255, green: 132/255, blue: 94/255, opacity: 1)
    static let black = ColorComponent(red: 0, green: 0, blue: 0, opacity: 1)
    static let white = ColorComponent(red: 255/255, green: 255/255, blue: 255/255, opacity: 1)
    
    static let gray = ColorComponent(red: 142/255, green: 142/255, blue: 147/255, opacity: 1)
    static let gray2 = ColorComponent(red: 174/255, green: 174/255, blue: 178/255, opacity: 1)
    static let gray3 = ColorComponent(red: 199/255, green: 199/255, blue: 204/255, opacity: 1)
    static let gray4 = ColorComponent(red: 209/255, green: 209/255, blue: 214/255, opacity: 1)
    static let gray5 = ColorComponent(red: 229/255, green: 229/255, blue: 234/255, opacity: 1)
    static let gray6 = ColorComponent(red: 242/255, green: 242/255, blue: 247/255, opacity: 1)
}

extension ColorComponent: View {
    var swiftUI: Color {
        switch storage {
        case .rgba(let red, let green, let blue, let opacity):
            return Color(
                red: red,
                green: green,
                blue: blue,
                opacity: opacity
            )
        case .semantic(let semantic):
            switch semantic {
            case "clear":
                return Color(red: 0, green: 0, blue: 0, opacity: 0)
            case "red":
                return Color(red: 255/255, green: 59/255, blue: 48/255, opacity: 1)
            case "orange":
                return Color(red: 255/255, green: 149/255, blue: 0/255, opacity: 1)
            case "yellow":
                return Color(red: 255/255, green: 204/255, blue: 0/255, opacity: 1)
            case "green":
                return Color(red: 52/255, green: 199/255, blue: 89/255, opacity: 1)
            case "mint":
                return Color(red: 0/255, green: 199/255, blue: 190/255, opacity: 1)
            case "teal":
                return Color(red: 48/255, green: 176/255, blue: 199/255, opacity: 1)
            case "cyan":
                return Color(red: 50/255, green: 173/255, blue: 230/255, opacity: 1)
            case "blue":
                return Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 1)
            case "navy":
                return Color(red: 0/255, green: 0/255, blue: 128/255, opacity: 1)
            case "indigo":
                return Color(red: 88/255, green: 86/255, blue: 214/255, opacity: 1)
            case "purple":
                return Color(red: 175/255, green: 82/255, blue: 222/255, opacity: 1)
            case "pink":
                return Color(red: 255/255, green: 45/255, blue: 85/255, opacity: 1)
            case "brown":
                return Color(red: 162/255, green: 132/255, blue: 94/255, opacity: 1)
            case "black":
                return Color(red: 0, green: 0, blue: 0, opacity: 1)
            case "white":
                return Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 1)
            case "gray":
                return Color(red: 142/255, green: 142/255, blue: 147/255, opacity: 1)
            case "gray2":
                return Color(red: 174/255, green: 174/255, blue: 178/255, opacity: 1)
            case "gray3":
                return Color(red: 199/255, green: 199/255, blue: 204/255, opacity: 1)
            case "gray4":
                return Color(red: 209/255, green: 209/255, blue: 214/255, opacity: 1)
            case "gray5":
                return Color(red: 229/255, green: 229/255, blue: 234/255, opacity: 1)
            case "gray6":
                return Color(red: 242/255, green: 242/255, blue: 247/255, opacity: 1)
            default:
                // Default to primary color (using blue as primary)
                return Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 1)
            }
        }
    }
    
    public var body: some View {
        swiftUI
    }
}
