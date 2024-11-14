import SwiftUI

struct ColorConvertible: ComponentConvertible {
    
    indirect enum Storage {
        case rgba(Double, Double, Double, Double)
        case name(String)
    }
    
    let storage: Storage
    
    init(_ storage: Storage) {
        self.storage = storage
    }
    
    init(_ component: Component) {
        if let name: String = component.decode("value") {
            storage = .name(name)
        } else if let white: Double = component.decode("value") {
            storage = .rgba(white, white, white, 1)
        } else {
            let red: Double? = component.decode("red")
            let green: Double? = component.decode("green")
            let blue: Double? = component.decode("blue")
            let alpha: Double? = component.decode("alpha")
            storage = .rgba(red ?? 0, green ?? 0, blue ?? 0, alpha ?? 1)
        }
    }
    
    var component: Component {
        switch storage {
        case .rgba(let red, let green, let blue, let alpha):
            return Component(type: Self.componentName, props: [
                "red": red,
                "green": green,
                "blue": blue,
                "alpha": alpha
            ])
        case .name(let name):
            return Component(type: Self.componentName, props: ["value": name])
        }
    }
}

extension ColorConvertible: View {
    
    var swiftUI: Color {
        switch storage {
        case .name(let name):
            switch name {
            case "clear":
                return Color.clear
            case "red":
                return Color.red
            case "orange":
                return Color.orange
            case "yellow":
                return Color.yellow
            case "green":
                return Color.green
            case "mint":
                return Color.mint
            case "teal":
                return Color.teal
            case "cyan":
                return Color.cyan
            case "blue":
                return Color.blue
            case "indigo":
                return Color.indigo
            case "purple":
                return Color.purple
            case "pink":
                return Color.pink
            case "brown":
                return Color.brown
            case "black":
                return Color.black
            case "white":
                return Color.white
            case "gray":
                return Color.gray
            case "primary":
                return Color.primary
            case "background":
                return Color(.textBackgroundColor)
            case "secondary":
                return Color.secondary
            case "accentColor":
                return Color.accentColor
            default:
                return Color.primary
            }
        case .rgba(let red, let green, let blue, let alpha):
            return Color(
                red: red,
                green: green,
                blue: blue,
                opacity: alpha
            )
        }
    }
    
    var body: some View {
        swiftUI
    }
}

extension ColorConvertible {
    static let black = ColorConvertible(.name("black"))
    static let white = ColorConvertible(.name("white"))
    static let clear = ColorConvertible(.name("clear"))
    static let red = ColorConvertible(.name("red"))
    static let orange = ColorConvertible(.name("orange"))
    static let yellow = ColorConvertible(.name("yellow"))
    static let green = ColorConvertible(.name("green"))
    static let mint = ColorConvertible(.name("mint"))
    static let teal = ColorConvertible(.name("teal"))
    static let cyan = ColorConvertible(.name("cyan"))
    static let blue = ColorConvertible(.name("blue"))
    static let indigo = ColorConvertible(.name("indigo"))
    static let purple = ColorConvertible(.name("purple"))
    static let pink = ColorConvertible(.name("pink"))
    static let brown = ColorConvertible(.name("brown"))
    static let gray = ColorConvertible(.name("gray"))
    static let primary = ColorConvertible(.name("primary"))
    static let secondary = ColorConvertible(.name("secondary"))
    static let accentColor = ColorConvertible(.name("accentColor"))
}
