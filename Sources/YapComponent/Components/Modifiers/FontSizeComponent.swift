import SwiftUI

struct FontSizeComponent: AutomaticComponentConvertible {
    var size: Double?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.size)
        ]
    }
}

extension FontSizeComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if let size {
            content.font(.system(size: size))
        } else {
            content
        }
    }
}
