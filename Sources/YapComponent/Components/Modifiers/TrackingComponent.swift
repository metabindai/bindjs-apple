import SwiftUI

struct TrackingComponent: AutomaticComponentConvertible {
    var value: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.value)
        ]
    }
}

extension TrackingComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.tracking(value)
        } else {
            content
        }
    }
}
