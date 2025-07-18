import SwiftUI

struct MultilineTextAlignmentComponent: Component {
    static var directiveName: String = "multilineTextAlignment"
    
    let alignment: TextAlignment
}

extension MultilineTextAlignmentComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        alignment = directive.rawValue() ?? .center
    }
}

extension MultilineTextAlignmentComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(alignment)
    }
}
