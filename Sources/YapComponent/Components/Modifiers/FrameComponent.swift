import SwiftUI

struct FrameComponent: AutomaticComponentConvertible {
    var width: Double?
    var height: Double?
    var alignment: AlignmentComponent = .center

    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("width", \Self.width),
            ("height", \Self.height),
            ("alignment", \Self.alignment)
        ]
    }
}

extension FrameComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(
                width: width.map { CGFloat($0) },
                height: height.map { CGFloat($0) },
                alignment: alignment.swiftUI
            )
    }
}
