import SwiftUI

struct UnknownComponent: Component {
    static var directiveName: String = "Unknown"
    
    let directive: Directive
    let children: [Component]
    
    init?(from directive: Directive) {
        self.directive = directive
        self.children = directive.children.compactMap(makeComponent(_:))
    }
}

extension UnknownComponent: View {
    
    var body: some View {
        ForEach(children.indices, id: \.self) { index in
            ComponentView(children[index])
        }
    }
}
