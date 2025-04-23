import SwiftUI

struct SaturationComponent: Component {
    static var directiveName: String = "saturation"
    
    let saturation: Double
}

extension SaturationComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        saturation = directive.rawValue() ?? 1
    }
}

extension SaturationComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .saturation(saturation)
    }
}
