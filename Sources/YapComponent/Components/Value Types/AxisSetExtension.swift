import SwiftUI

extension String {
    var axisSet: Axis.Set {
        switch self {
        case "vertical":
            return .vertical
        case "horizontal":
            return .horizontal
        case "both":
            return [.vertical, .horizontal]
        default:
            return .vertical
        }
    }
}

extension Axis.Set {
    var string: String {
        switch self {
        case .vertical:
            return "vertical"
        case .horizontal:
            return "horizontal"
        case [.vertical, .horizontal]:
            return "both"
        default:
            return "vertical"  // Match the default case from String conversion
        }
    }
}
