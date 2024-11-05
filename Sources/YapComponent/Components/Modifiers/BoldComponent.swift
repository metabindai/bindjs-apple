import SwiftUI

struct BoldComponent: AutomaticComponentConvertible {
    var isActive: Bool = true
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.isActive)
        ]
    }
}

extension BoldComponent: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.bold(isActive)
        } else {
            content
        }
    }
}
