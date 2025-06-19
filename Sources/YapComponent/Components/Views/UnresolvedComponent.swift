import SwiftUI

struct UnresolvedComponent: Component {
    static var directiveName: String = "Unresolved"
    
    let directive: Directive
    let children: [Component]
    
    init?(from directive: Directive) {
        self.directive = directive
        self.children = directive.children.compactMap(makeComponent(_:))
    }
}

extension UnresolvedComponent: View {
    
    var body: some View {
        ForEach(children.indices, id: \.self) { index in
            ComponentView(children[index])
        }
    }
}
