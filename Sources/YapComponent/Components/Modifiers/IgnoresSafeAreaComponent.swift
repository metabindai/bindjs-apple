import SwiftUI

struct IgnoresSafeAreaComponent: AutomaticComponentConvertible {
    var isActive: Bool = false
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("isActive", \Self.isActive)
        ]
    }
}

extension IgnoresSafeAreaComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.ignoresSafeArea(isActive ? .all : [])
    }
}
