import SwiftUI

extension Array where Element == Double {
    var unitPoint: UnitPoint {
        switch count {
        case 0:
            return .center
        case 1:
            return UnitPoint(x: self[0], y: self[0])
        case 2:
            return UnitPoint(x: self[0], y: self[1])
        default:
            return UnitPoint(x: self[0], y: self[1])
        }
    }
}

extension UnitPoint {
    var array: [Double] {
        // If x and y are the same, return single value
        if x == y {
            return [x]
        }
        return [x, y]
    }
}

extension String {
    var unitPoint: UnitPoint {
        switch self.lowercased() {
        case "center":
            return .center
        case "top":
            return .top
        case "topleading", "top-leading", "top_leading":
            return .topLeading
        case "toptrailing", "top-trailing", "top_trailing":
            return .topTrailing
        case "bottom":
            return .bottom
        case "bottomleading", "bottom-leading", "bottom_leading":
            return .bottomLeading
        case "bottomtrailing", "bottom-trailing", "bottom_trailing":
            return .bottomTrailing
        case "leading":
            return .leading
        case "trailing":
            return .trailing
        case "zero":
            return .zero
        default:
            return .center
        }
    }
}

extension UnitPoint {
    var string: String {
        switch self {
        case .center:
            return "center"
        case .top:
            return "top"
        case .topLeading:
            return "topLeading"
        case .topTrailing:
            return "topTrailing"
        case .bottom:
            return "bottom"
        case .bottomLeading:
            return "bottomLeading"
        case .bottomTrailing:
            return "bottomTrailing"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        case .zero:
            return "zero"
        default:
            // For custom points that don't match standard positions
            return "center"
        }
    }
}
