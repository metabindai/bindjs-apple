import SwiftUI

struct TrackingComponent: Component {
    static var directiveName: String = "tracking"
    
    let tracking: CGFloat
}

extension TrackingComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        tracking = directive.rawValue() ?? 0
    }
}

extension TrackingComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tracking(tracking)
    }
}
