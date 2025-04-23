import SwiftUI

struct CornerRadiusComponent: Component {
    static var directiveName: String = "cornerRadius"
    
    let radius: CGFloat
}

extension CornerRadiusComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        radius = directive.rawValue() ?? 0
    }
}

extension CornerRadiusComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(radius)
    }
}
