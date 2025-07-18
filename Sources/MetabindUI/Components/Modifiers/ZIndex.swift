import SwiftUI

struct ZIndexComponent: Component {
    static var directiveName: String = "zIndex"
    
    let zIndex: Double
}

extension ZIndexComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        zIndex = directive.rawValue() ?? 0
    }
}

extension ZIndexComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .zIndex(zIndex)
    }
}
