import SwiftUI

struct AspectRatioComponent: AutomaticComponentConvertible {
    var aspectRatio: Double = 1.0
    var contentMode: ContentModeComponent = .fit
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("aspectRatio", \Self.aspectRatio),
            ("contentMode", \Self.contentMode)
        ]
    }
}

extension AspectRatioComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.aspectRatio(
            aspectRatio,
            contentMode: contentMode.swiftUI
        )
    }
}
