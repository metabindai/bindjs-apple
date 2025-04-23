import SwiftUI

struct GrayscaleComponent: Component {
    static var directiveName: String = "grayscale"
    
    let grayscale: Double
}

extension GrayscaleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        grayscale = directive.rawValue() ?? 1
    }
}

extension GrayscaleComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .grayscale(grayscale)
    }
}
