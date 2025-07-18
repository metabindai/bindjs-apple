import SwiftUI

struct LineLimitComponent: Component {
    static var directiveName: String = "lineLimit"
    
    let lineLimit: Int?
}

extension LineLimitComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        lineLimit = directive.rawValue()
    }
}

extension LineLimitComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(lineLimit)
    }
}
