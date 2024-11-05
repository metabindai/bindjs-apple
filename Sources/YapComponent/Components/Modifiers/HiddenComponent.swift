import SwiftUI

struct HiddenComponent: AutomaticComponentConvertible {
    var isActive: Bool = true
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.isActive)
        ]
    }
}

extension HiddenComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if isActive {
            content.hidden()
        } else {
            content
        }
    }
}
