import SwiftUI

struct ItalicComponent: AutomaticComponentConvertible {
    var isActive: Bool = true
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.isActive)
        ]
    }
}

extension ItalicComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.italic(isActive)
        } else {
            content
        }
    }
}
