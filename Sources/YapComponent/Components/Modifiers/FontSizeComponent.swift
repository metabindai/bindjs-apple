import SwiftUI

struct FontSizeComponent: AutomaticComponentConvertible {
    var size: Double = 15.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("size", \Self.size)
        ]
    }
}

extension FontSizeComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.font(.system(size: size))
    }
}
