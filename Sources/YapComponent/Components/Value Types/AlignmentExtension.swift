import SwiftUI

extension String {
    public var alignment: Alignment {
        switch self {
        case "topLeading": return .topLeading
        case "top": return .top
        case "topTrailing": return .topTrailing
        case "leading": return .leading
        case "center": return .center
        case "trailing": return .trailing
        case "bottomLeading": return .bottomLeading
        case "bottom": return .bottom
        case "bottomTrailing": return .bottomTrailing
        default: return .center // Default to center alignment if string doesn't match
        }
    }
}

extension String {
    var horizontalAlignment: HorizontalAlignment {
        switch self.lowercased() {
        case "leading":
            return .leading
        case "center":
            return .center
        case "trailing":
            return .trailing
        case "listrowseparatortrailing":
            return .listRowSeparatorTrailing
        case "listrowseparatorleading":
            return .listRowSeparatorLeading
        default:
            return .center
        }
    }
}

extension HorizontalAlignment {
    var string: String {
        switch self {
        case .leading:
            return "leading"
        case .center:
            return "center"
        case .trailing:
            return "trailing"
        case .listRowSeparatorTrailing:
            return "listRowSeparatorTrailing"
        case .listRowSeparatorLeading:
            return "listRowSeparatorLeading"
        default:
            return "center"
        }
    }
}
