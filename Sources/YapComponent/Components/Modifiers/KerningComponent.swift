import SwiftUI

struct KerningComponent: AutomaticComponentConvertible {
    var value: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("value", \Self.value)
        ]
    }
}

extension KerningComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.kerning(value)
        } else {
            content
        }
    }
}
