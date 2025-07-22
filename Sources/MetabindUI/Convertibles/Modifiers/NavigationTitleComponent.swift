import Foundation
import SwiftUI

struct NavigationTitleComponent: Component {
    static var directiveName: String = "navigationTitle"
    
    let title: String
}

extension NavigationTitleComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        title = directive["title"] ?? ""
    }
}

extension NavigationTitleComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
    }
}