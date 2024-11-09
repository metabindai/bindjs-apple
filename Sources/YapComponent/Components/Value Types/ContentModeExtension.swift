import SwiftUI

extension String {
    var contentMode: ContentMode {
        switch self {
        case "fit":
            return .fit
        case "fill":
            return .fill
        default:
            return .fit
        }
    }
}
