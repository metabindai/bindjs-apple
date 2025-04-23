import SwiftUI

struct OffsetComponent: Component {
    static var directiveName: String = "offset"
    
    let x: CGFloat
    let y: CGFloat
}

extension OffsetComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        x = directive["x"] ?? 0
        y = directive["y"] ?? 0
    }
}

extension OffsetComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .offset(x: x, y: y)
    }
}
