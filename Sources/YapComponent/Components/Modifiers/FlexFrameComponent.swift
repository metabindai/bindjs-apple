import SwiftUI

struct FlexFrameComponent: AutomaticComponentConvertible {
    var minWidth: Double?
    var idealWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var idealHeight: Double?
    var maxHeight: Double?
    var alignment: String = "center"
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("minWidth", \Self.minWidth),
            ("idealWidth", \Self.idealWidth),
            ("maxWidth", \Self.maxWidth),
            ("minHeight", \Self.minHeight),
            ("idealHeight", \Self.idealHeight),
            ("maxHeight", \Self.maxHeight),
            ("alignment", \Self.alignment)
        ]
    }
}

extension FlexFrameComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: minWidth.map { CGFloat($0) },
                idealWidth: idealWidth.map { CGFloat($0) },
                maxWidth: maxWidth.map { CGFloat($0) },
                minHeight: minHeight.map { CGFloat($0) },
                idealHeight: idealHeight.map { CGFloat($0) },
                maxHeight: maxHeight.map { CGFloat($0) },
                alignment: alignment.alignment
            )
    }
}
