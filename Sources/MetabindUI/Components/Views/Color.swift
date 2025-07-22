import SwiftUI

public struct ColorComponent: Component {
    public static var directiveName: String = "Color"
    
    public enum Storage {
        case name(String)
        case rgba(Double, Double, Double, Double)
    }
    
    public let storage: Storage
    public let opacity: Double
}

extension ColorComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let name: String = directive.rawValue() {
            storage = .name(name)
        } else {
            let red: Double = (directive["r"] ?? 0) / 255
            let green: Double = (directive["g"] ?? 0) / 255
            let blue: Double = (directive["b"] ?? 0) / 255
            let alpha: Double = directive["a"] ?? 1
            storage = .rgba(red, green, blue, alpha)
        }
        opacity = directive["opacity"] ?? 1
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitColor(self)
    }
}

extension ColorComponent: View {
    var swiftUI: Color {
        switch storage {
        case .name(let name):
            (Self.namedColors[name] ?? .primary).opacity(opacity)
        case .rgba(let red, let green, let blue, let alpha):
            Color(red: red, green: green, blue: blue, opacity: alpha)
                .opacity(opacity)
        }
    }
    
    public var body: some View {
        swiftUI
    }
}

extension ColorComponent {
    private static let namedColors: [String: Color] = [
        "clear": .clear,
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "mint": .mint,
        "teal": .teal,
        "cyan": .cyan,
        "blue": .blue,
        "indigo": .indigo,
        "purple": .purple,
        "pink": .pink,
        "brown": .brown,
        "black": .black,
        "white": .white,
        "gray": .gray,
        "primary": .primary,
        "background": {
            #if os(macOS)
                return Color(.textBackgroundColor)
            #else
                return Color(.systemBackground)
            #endif
        }(),
        "secondary": .secondary,
        "accentColor": .accentColor,
        "accent": .accentColor,
        "tertiary": {
            #if os(macOS)
                return Color(.tertiaryLabelColor)
            #else
                return Color(.tertiaryLabel)
            #endif
        }(),
        "quaternary": {
            #if os(macOS)
                return Color(.quaternaryLabelColor)
            #else
                return Color(.quaternaryLabel)
            #endif
        }()
    ]
}
