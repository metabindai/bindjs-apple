import SwiftUI

struct BrightnessComponent: Component {
    static var directiveName: String = "brightness"
    
    let brightness: Double
}

extension BrightnessComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        brightness = directive.rawValue() ?? 0
    }
}

extension BrightnessComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .brightness(brightness)
    }
}
