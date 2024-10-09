import SwiftUI

struct HiddenComponent: AutomaticComponentConvertible {
    var isActive: Bool = true
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("isActive", \Self.isActive)
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
