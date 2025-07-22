import SwiftUI

protocol ParsableArgument {
    init?(rawValue: String)
}

extension LosslessStringConvertible where Self: ParsableArgument {
    init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension Double: ParsableArgument {}

extension CGFloat: ParsableArgument {
    init?(rawValue: String) {
        if let doubleValue = Double(rawValue) {
            self.init(doubleValue)
        } else {
            return nil
        }
    }
}

extension URL: ParsableArgument {
    init?(rawValue: String) {
        if let url = URL(string: rawValue) {
            self = url
        } else {
            return nil
        }
    }
}

extension Int: ParsableArgument {
    init?(rawValue: String) {
        if let doubleValue = Double(rawValue) {
            self.init(doubleValue)
        } else {
            return nil
        }
    }
}

extension Bool: ParsableArgument {}

extension String: ParsableArgument {}

extension HorizontalAlignment: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "leading": self = .leading
        case "center": self = .center
        case "trailing": self = .trailing
        default: return nil
        }
    }
}

extension VerticalAlignment: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "top": self = .top
        case "center": self = .center
        case "bottom": self = .bottom
        case "firstTextBaseline": self = .firstTextBaseline
        case "lastTextBaseline": self = .lastTextBaseline
        default: return nil
        }
    }
}

extension Alignment: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "center": self = .center
        case "leading": self = .leading
        case "trailing": self = .trailing
        case "top": self = .top
        case "bottom": self = .bottom
        case "topLeading": self = .topLeading
        case "topTrailing": self = .topTrailing
        case "bottomLeading": self = .bottomLeading
        case "bottomTrailing": self = .bottomTrailing
        default: return nil
        }
    }
}

extension ColorScheme: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}

extension DynamicTypeSize: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "small": self = .small
        case "medium": self = .medium
        case "large": self = .large
        case "xLarge": self = .xLarge
        case "xxLarge": self = .xxLarge
        case "xxxLarge": self = .xxxLarge
        case "accessibility1": self = .accessibility1
        case "accessibility2": self = .accessibility2
        case "accessibility3": self = .accessibility3
        case "accessibility4": self = .accessibility4
        case "accessibility5": self = .accessibility5
        default: return nil
        }
    }
}

extension TextAlignment: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "leading": self = .leading
        case "center": self = .center
        case "trailing": self = .trailing
        default: return nil
        }
    }
}

extension Text.Case: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "uppercase": self = .uppercase
        case "lowercase": self = .lowercase
        default: return nil
        }
    }
}

extension ControlSize: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "mini": self = .mini
        case "small": self = .small
        case "regular": self = .regular
        case "large": self = .large
        case "extraLarge": if #available(macOS 14.0, iOS 17.0, *) {
            self = .extraLarge
        } else {
            self = .large
        }
        default:
            return nil
        }
    }
}

extension Font.Design: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "default": self = .default
        case "serif": self = .serif
        case "monospaced": self = .monospaced
        case "rounded": self = .rounded
        default: return nil
        }
    }
}

extension Font.Weight: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
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

extension Font.Width: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "compressed": self = .compressed
        case "condensed": self = .condensed
        case "standard": self = .standard
        case "expanded": self = .expanded
        default:
            if let doubleValue = Double(rawValue) {
                self = .init(doubleValue)
            } else {
                return nil
            }
        }
    }
}

extension Font.TextStyle: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "caption2": self = .caption2
        case "caption": self = .caption
        case "footnote": self = .footnote
        case "subheadline": self = .subheadline
        case "headline": self = .headline
        case "body": self = .body
        case "callout": self = .callout
        case "largeTitle": self = .largeTitle
        case "title": self = .title
        case "title2": self = .title2
        case "title3": self = .title3
        default: return nil
        }
    }
}

extension BlendMode: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "normal": self = .normal
        case "multiply": self = .multiply
        case "screen": self = .screen
        case "overlay": self = .overlay
        case "darken": self = .darken
        case "lighten": self = .lighten
        case "colorDodge": self = .colorDodge
        case "colorBurn": self = .colorBurn
        case "softLight": self = .softLight
        case "hardLight": self = .hardLight
        case "difference": self = .difference
        case "exclusion": self = .exclusion
        case "hue": self = .hue
        case "saturation": self = .saturation
        case "color": self = .color
        case "luminosity": self = .luminosity
        case "sourceAtop": self = .sourceAtop
        case "destinationOver": self = .destinationOver
        case "destinationOut": self = .destinationOut
        case "plusDarker": self = .plusDarker
        case "plusLighter": self = .plusLighter
        default: return nil
        }
    }
}

extension Material: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "ultraThin": self = .ultraThin
        case "thin": self = .thin
        case "regular": self = .regular
        case "thick": self = .thick
        case "ultraThick": self = .ultraThick
        default: return nil
        }
    }
}

extension UnitPoint: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "top": self = .top
        case "bottom": self = .bottom
        case "leading": self = .leading
        case "trailing": self = .trailing
        case "topLeading": self = .topLeading
        case "topTrailing": self = .topTrailing
        case "bottomLeading": self = .bottomLeading
        case "bottomTrailing": self = .bottomTrailing
        case "center": self = .center
        default: return nil
        }
    }
}

extension Axis.Set: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "horizontal": self = .horizontal
        case "vertical": self = .vertical
        case "both": self = [.horizontal, .vertical]
        default: return nil
        }
    }
}

extension Edge.Set: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "top": self = .top
        case "leading": self = .leading
        case "bottom": self = .bottom
        case "trailing": self = .trailing
        case "horizontal": self = .horizontal
        case "vertical": self = .vertical
        case "all": self = .all
        default: return nil
        }
    }
}

extension ButtonRole: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "destructive": self = .destructive
        case "cancel": self = .cancel
        default: return nil
        }
    }
}

extension ContentMode: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "fit": self = .fit
        case "fill": self = .fill
        default: return nil
        }
    }
}

extension SafeAreaRegions: ParsableArgument {
    init?(rawValue: String) {
        switch rawValue {
        case "container": self = .container
        case "keyboard": self = .keyboard
        case "all": self = .all
        default: return nil
        }
    }
}

public enum TextSelectabilityArgument: ParsableArgument {
    case enabled
    case disabled
    
    init?(rawValue: String) {
        switch rawValue {
        case "enabled": self = .enabled
        case "disabled": self = .disabled
        default: return nil
        }
    }
}
