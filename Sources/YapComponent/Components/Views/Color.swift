import SwiftUI

struct ColorComponent: Component {
    static var directiveName: String = "Color"
    
    enum Storage {
        case name(String)
        case rgba(Double, Double, Double, Double)
    }
    
    let storage: Storage
    let opacity: Double
}

extension ColorComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        if let name: String = directive.rawValue() {
            storage = .name(name)
        } else {
            let red: Double = directive["red"] ?? 0
            let green: Double = directive["green"] ?? 0
            let blue: Double = directive["blue"] ?? 0
            let alpha: Double = directive["alpha"] ?? 1
            storage = .rgba(red, green, blue, alpha)
        }
        opacity = directive["opacity"] ?? 1
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
    
    var body: some View {
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
