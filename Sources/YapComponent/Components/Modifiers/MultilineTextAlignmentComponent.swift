import SwiftUI

struct MultiLineTextAlignmentComponent: AutomaticComponentConvertible {
    var alignment: HorizontalAlignmentComponent = .leading
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.alignment)
        ]
    }
}

extension MultiLineTextAlignmentComponent: ViewModifier {
    var swiftUI: TextAlignment {
        switch self.alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(swiftUI)
    }
}
