import SwiftUI

struct AspectRatioComponent: AutomaticComponentConvertible {
    var aspectRatio: Double = 1.0
    var contentMode: String = "fit"
    var rawValue: Double?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("aspectRatio", \Self.aspectRatio),
            ("contentMode", \Self.contentMode),
            ("rawValue", \Self.rawValue)
        ]
    }
}

extension AspectRatioComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.aspectRatio(
            rawValue ?? aspectRatio,
            contentMode: contentMode.contentMode
        )
    }
}
