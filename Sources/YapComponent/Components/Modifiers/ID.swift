import SwiftUI

struct IDComponent: Component {
    static var directiveName: String = "id"
    
    let id: String
}

extension IDComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        id = directive.rawValue() ?? ""
    }
}

extension IDComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .id(id)
    }
}
