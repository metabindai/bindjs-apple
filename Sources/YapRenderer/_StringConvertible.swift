import SwiftUI
import YapComponent

@dynamicMemberLookup
struct Props {
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    subscript<T: _StringConvertible>(dynamicMember member: String) -> T? {
        if let prop = directive.enclosedContext!.get(member) {
            return T(String(describing: prop))
        }
        return nil
    }
    
    subscript(dynamicMember member: String) -> Component? {
        return directive.enclosedContext!.get(member)
    }
    
    func first(where predicate: (Component) throws -> Bool) rethrows -> Component? {
        try directive.props.values.first(where: predicate)
    }
}


func ~= <T: RawRepresentable>(lhs: T.Type, rhs: T.RawValue) -> Bool where T.RawValue: Hashable, T: CaseIterable {
    T.allCases.map(\.rawValue).contains(rhs)
}

public protocol _StringConvertible {
    init?(_ string: String)
    var description: String { get }
}

public protocol _DirectriveConvertible {
    init?(_ directive: Directive)
    var directive: Directive { get }
}

extension CGFloat: _StringConvertible {
    public init?(_ string: String) {
        if let double = Double(string) {
            self = CGFloat(double)
        } else {
            return nil
        }
    }
}

extension String: _StringConvertible {}

extension Int: _StringConvertible {}

extension Bool: _StringConvertible {}

extension Double: _StringConvertible {}

extension Axis.Set: _StringConvertible {
    public var description: String {
        var axes: [String] = []
        if contains(.horizontal) { axes.append("horizontal") }
        if contains(.vertical) { axes.append("vertical") }
        if axes.isEmpty { return "none" }
        return axes.joined(separator: " ")
    }
    
    public init?(_ string: String) {
        let parts = string.split(separator: " ").map(String.init)
        var axes: Axis.Set = []
        for part in parts {
            switch part.lowercased() {
            case "horizontal": axes.insert(.horizontal)
            case "vertical": axes.insert(.vertical)
            default: return nil
            }
        }
        self = axes
    }
}

extension TextAlignment: _StringConvertible {
    public var description: String {
        switch self {
        case .leading: return "leading"
        case .center: return "center"
        case .trailing: return "trailing"
        case .center: return "center"
        }
    }
    
    public init?(_ string: String) {
        switch string.lowercased() {
        case "leading": self = .leading
        case "center": self = .center
        case "trailing": self = .trailing
        default: return nil
        }
    }
}

extension HorizontalAlignment: _StringConvertible {
    
    public var description: String {
        if #available(iOS 16.0, *) {
            switch self {
            case .leading: return "leading"
            case .center: return "center"
            case .trailing: return "trailing"
            case .listRowSeparatorLeading: return "listRowSeparatorLeading"
            case .listRowSeparatorTrailing: return "listRowSeparatorTrailing"
            default : return "unknown"
            }
        } else {
            switch self {
            case .leading: return "leading"
            case .center: return "center"
            case .trailing: return "trailing"
            default : return "unknown"
            }
        }
    }
    
    public init?(_ string: String) {
        switch string {
        case "leading": self = .leading
        case "center": self = .center
        case "trailing": self = .trailing
        case "listRowSeparatorLeading": if #available(iOS 16.0, *) {
            self = .listRowSeparatorLeading
        } else {
            self = .leading
        }
        case "listRowSeparatorTrailing": if #available(iOS 16.0, *) {
            self = .listRowSeparatorTrailing
        } else {
            self = .trailing
        }
        default: return nil
        }
    }
}

extension VerticalAlignment: _StringConvertible {
    public var description: String {
        switch self {
        case .top: return "top"
        case .center: return "center"
        case .bottom: return "bottom"
        case .firstTextBaseline: return "firstTextBaseline"
        case .lastTextBaseline: return "lastTextBaseline"
        default : return "unknown"
        }
    }
    
    public init?(_ string: String) {
        switch string {
        case "top": self = .top
        case "center": self = .center
        case "bottom": self = .bottom
        case "firstTextBaseline": self = .firstTextBaseline
        case "lastTextBaseline": self = .lastTextBaseline
        default: return nil
        }
    }
}

extension Alignment: _StringConvertible {
    public var description: String {
        "\(vertical.description) \(horizontal.description)"
    }
    
    public init?(_ string: String) {
        let parts = string.split(separator: " ").map(String.init)
        guard parts.count == 2 else { return nil }
        
        guard let vertical = VerticalAlignment(parts[0]) else { return nil }
        guard let horizontal = HorizontalAlignment(parts[1]) else { return nil }
        
        self = .init(horizontal: horizontal, vertical: vertical)
    }
}

extension Font: _StringConvertible {
    public var description: String {
        switch self {
        case .caption2: return "caption2"
        case .caption: return "caption"
        case .footnote: return "footnote"
        case .body: return "body"
        case .callout: return "callout"
        case .subheadline: return "subheadline"
        case .headline: return "headline"
        case .title3: return "title3"
        case .title2: return "title2"
        case .title: return "title"
        case .largeTitle: return "largeTitle"
        default: return "unknown"
        }
    }
    
    public init?(_ description: String) {
        switch description {
        case "caption2": self = .caption2
        case "caption": self = .caption
        case "footnote": self = .footnote
        case "body": self = .body
        case "callout": self = .callout
        case "subheadline": self = .subheadline
        case "headline": self = .headline
        case "title3": self = .title3
        case "title2": self = .title2
        case "title": self = .title
        case "largeTitle": self = .largeTitle
        default: return nil
        }
    }
}

extension Font.Weight: _StringConvertible {
    public var description: String {
        switch self {
        case .ultraLight: return "ultraLight"
        case .thin: return "thin"
        case .light: return "light"
        case .regular: return "regular"
        case .medium: return "medium"
        case .semibold: return "semibold"
        case .bold: return "bold"
        case .heavy: return "heavy"
        case .black: return "black"
        default: return "unknown"
        }
    }
    
    public init?(_ description: String) {
        switch description {
        case "ultraLight": self = .ultraLight
        case "thin": self = .thin
        case "light": self = .light
        case "regular": self = .regular
        case "medium": self = .medium
        case "semibold": self = .semibold
        case "bold": self = .bold
        case "heavy": self = .heavy
        case "black": self = .black
        default: return nil
        }
    }
}


extension Font.Design: _StringConvertible {
    public var description: String {
        switch self {
        case .default: return "default"
        case .serif: return "serif"
        case .rounded: return "rounded"
        case .monospaced: return "monospaced"
        default: return "unknown"
        }
    }
    
    public init?(_ description: String) {
        switch description {
        case "default": self = .default
        case "serif": self = .serif
        case "rounded": self = .rounded
        case "monospaced": self = .monospaced
        default: return nil
        }
    }
}

@available(iOS 16.0, *)
extension Font.Width: _StringConvertible {
    public var description: String {
        switch self {
        case .compressed: return "ultraCondensed"
        case .condensed: return "condensed"
        case .expanded: return "expanded"
        case .standard: return "standard"
        default: return "unknown"
        }
    }
    
    public init?(_ description: String) {
        switch description {
        case "compressed": self = .compressed
        case "condensed": self = .condensed
        case "expanded": self = .expanded
        case "standard": self = .standard
        default: return nil
        }
    }
}


extension Color: _StringConvertible {
    public var description: String {
        // Resolve the color to get its RGBA components
#if canImport(UIKit)
        // For iOS, tvOS, and watchOS
        let uiColor = UIColor(self)
        let color = uiColor.resolvedColor(with: UITraitCollection())
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        uiColor.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)
#elseif canImport(AppKit)
        // For macOS
        let nsColor = NSColor(self)
        let color = nsColor.usingColorSpace(.sRGB) ?? nsColor
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        color.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)
#endif
        
        // Convert components to integers between 0 and 255
        let redInt = Int(round(redComponent * 255))
        let greenInt = Int(round(greenComponent * 255))
        let blueInt = Int(round(blueComponent * 255))
        let alphaInt = Int(round(alphaComponent * 255))
        
        // Format as hex string
        if alphaInt < 255 {
            // Include alpha component if it's less than 1.0
            return String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        } else {
            // Omit alpha component if it's fully opaque
            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        }
    }
    
    public init?(_ string: String) {
        var trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Define a mapping from color names to Colors
        let colorNames: [String: Color] = [
            "black": .black,
            "white": .white,
            "gray": .gray,
            "red": .red,
            "green": .green,
            "blue": .blue,
            "cyan": .cyan,
            "yellow": .yellow,
            "orange": .orange,
            "purple": .purple,
            "pink": .pink,
            "brown": .brown,
            "clear": .clear,
            "primary": .primary,
            "secondary": .secondary
        ]
        
        // Remove spaces and handle special characters
        trimmedString = trimmedString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        
        // Check if the string matches any of the color names
        if let namedColor = colorNames[trimmedString] {
            self = namedColor
            return
        } else {
            // Proceed with hex parsing
            // Remove leading "#" or "0x" or "0X"
            if trimmedString.hasPrefix("#") {
                trimmedString = String(trimmedString.dropFirst())
            } else if trimmedString.hasPrefix("0x") {
                trimmedString = String(trimmedString.dropFirst(2))
            }
            
            let length = trimmedString.count
            
            var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0, alpha: UInt64 = 255
            
            switch length {
            case 3: // RGB (12-bit)
                // Duplicate each character, e.g., "abc" -> "aabbcc"
                let rStr = String(repeating: trimmedString[trimmedString.startIndex], count: 2)
                let gIndex = trimmedString.index(trimmedString.startIndex, offsetBy: 1)
                let gStr = String(repeating: trimmedString[gIndex], count: 2)
                let bIndex = trimmedString.index(trimmedString.startIndex, offsetBy: 2)
                let bStr = String(repeating: trimmedString[bIndex], count: 2)
                
                Scanner(string: rStr).scanHexInt64(&red)
                Scanner(string: gStr).scanHexInt64(&green)
                Scanner(string: bStr).scanHexInt64(&blue)
                
            case 6: // RRGGBB (24-bit)
                let rStr = String(trimmedString.prefix(2))
                let gStr = String(trimmedString.dropFirst(2).prefix(2))
                let bStr = String(trimmedString.dropFirst(4).prefix(2))
                
                Scanner(string: rStr).scanHexInt64(&red)
                Scanner(string: gStr).scanHexInt64(&green)
                Scanner(string: bStr).scanHexInt64(&blue)
                
            case 8: // RRGGBBAA (32-bit)
                let rStr = String(trimmedString.prefix(2))
                let gStr = String(trimmedString.dropFirst(2).prefix(2))
                let bStr = String(trimmedString.dropFirst(4).prefix(2))
                let aStr = String(trimmedString.dropFirst(6).prefix(2))
                
                Scanner(string: rStr).scanHexInt64(&red)
                Scanner(string: gStr).scanHexInt64(&green)
                Scanner(string: bStr).scanHexInt64(&blue)
                Scanner(string: aStr).scanHexInt64(&alpha)
                
            default:
                // Invalid length
                return nil
            }
            
            // Convert values to Double between 0 and 1
            let redDouble = Double(red) / 255.0
            let greenDouble = Double(green) / 255.0
            let blueDouble = Double(blue) / 255.0
            let alphaDouble = Double(alpha) / 255.0
            
            self.init(red: redDouble, green: greenDouble, blue: blueDouble, opacity: alphaDouble)
        }
    }
}

extension Color: _DirectriveConvertible {
    public var directive: Directive {
        Directive("Color", self.description)
    }
    
    public init?(_ directive: Directive) {
        guard directive.type == "Color" else { return nil }
        if let fromString = Color(directive.props["_0"] as? String ?? "") {
            self = fromString
        } else {
            return nil
        }
    }
}

extension UnitPoint: _StringConvertible {
    public var description: String {
        "\(x) \(y)"
    }
    
    public init?(_ string: String) {
        switch string {
        case "center": self = .center; return;
        case "top": self = .top; return;
        case "leading": self = .leading; return;
        case "bottom": self = .bottom; return;
        case "trailing": self = .trailing; return;
        case "topLeading": self = .topLeading; return;
        case "topTrailing": self = .topTrailing; return;
        case "bottomLeading": self = .bottomLeading; return;
        case "bottomTrailing": self = .bottomTrailing; return;
        case "zero": self = .zero; return;
        default: break
        }
        let parts = string.split(separator: " ").map(String.init)
        guard parts.count == 2 else { return nil }
        guard let x = Double(parts[0]), let y = Double(parts[1]) else { return nil }
        self = .init(x: x, y: y)
    }
}

extension URL: _StringConvertible {
    public init?(_ string: String) {
        guard let url = URL(string: string) else { return nil }
        self = url
    }
}

extension Edge.Set: _StringConvertible {
    public var description: String {
        var edges: [String] = []
        if contains(.all) { edges.append("all") }
        if contains(.top) { edges.append("top") }
        if contains(.leading) { edges.append("leading") }
        if contains(.bottom) { edges.append("bottom") }
        if contains(.trailing) { edges.append("trailing") }
        if contains(.horizontal) { edges.append("horizontal") }
        if contains(.vertical) { edges.append("vertical") }
        if edges.isEmpty { return "none" }
        return edges.joined(separator: " ")
    }
    
    public init?(_ string: String) {
        let parts = string.split(separator: " ").map(String.init)
        var edges: Edge.Set = []
        for part in parts {
            switch part {
            case "all": edges.insert(.all)
            case "top": edges.insert(.top)
            case "leading": edges.insert(.leading)
            case "bottom": edges.insert(.bottom)
            case "trailing": edges.insert(.trailing)
            case "horizontal": edges.insert(.horizontal)
            case "vertical": edges.insert(.vertical)
            default: return nil
            }
        }
        self = edges
    }
}

extension ColorScheme: _StringConvertible {
    public var description: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: return "unknown"
        }
    }
    
    public init?(_ string: String) {
        switch string {
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}

extension ContentMode: _StringConvertible {
    public init?(_ string: String) {
        switch string {
        case "fit": self = .fit
        case "fill": self = .fill
        default: return nil
        }
    }
    
    public var description: String {
        switch self {
        case .fit: return "fit"
        case .fill: return "fill"
        }
    }
}

extension Material: _StringConvertible {
    public var description: String {
        if String(describing: self) == String(describing: Material.bar) {
            return "bar"
        }
        if String(describing: self) == String(describing: Material.regular) {
            return "regular"
        }
        if String(describing: self) == String(describing: Material.thick) {
            return "thick"
        }
        if String(describing: self) == String(describing: Material.thin) {
            return "thin"
        }
        if String(describing: self) == String(describing: Material.ultraThin) {
            return "ultraThin"
        }
        if String(describing: self) == String(describing: Material.ultraThick) {
            return "ultraThick"
        }
        return "unknown"
    }
    
    public init?(_ string: String) {
        switch string {
        case "bar": self = Material.bar
        case "regular": self = Material.regular
        case "thick": self = Material.thick
        case "thin": self = Material.thin
        case "ultraThin": self = Material.ultraThin
        case "ultraThick": self = Material.ultraThick
        default: return nil
        }
    }
}

