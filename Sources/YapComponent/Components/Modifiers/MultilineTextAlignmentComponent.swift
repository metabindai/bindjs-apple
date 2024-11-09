import SwiftUI

struct MultiLineTextAlignmentComponent: AutomaticComponentConvertible {
    var alignment: String = "leading"
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.alignment)
        ]
    }
}

extension MultiLineTextAlignmentComponent: ViewModifier {
    var swiftUI: TextAlignment {
        switch self.alignment {
        case "leading":
            return .leading
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
    }
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(swiftUI)
    }
}
