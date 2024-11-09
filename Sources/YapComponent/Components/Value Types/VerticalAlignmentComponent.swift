import SwiftUI

extension String {
    var verticalAlignment: VerticalAlignment {
        switch self.lowercased() {
        case "top":
            return .top
        case "center":
            return .center
        case "bottom":
            return .bottom
        case "firsttextbaseline", "first-text-baseline", "first_text_baseline":
            return .firstTextBaseline
        case "lasttextbaseline", "last-text-baseline", "last_text_baseline":
            return .lastTextBaseline
        default:
            return .center
        }
    }
}

extension VerticalAlignment {
    var string: String {
        switch self {
        case .top:
            return "top"
        case .center:
            return "center"
        case .bottom:
            return "bottom"
        case .firstTextBaseline:
            return "firstTextBaseline"
        case .lastTextBaseline:
            return "lastTextBaseline"
        default:
            return "center"
        }
    }
}
