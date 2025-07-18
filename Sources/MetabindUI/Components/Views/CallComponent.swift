import SwiftUI

struct CallComponent: Component {
    static var directiveName: String = "ComponentCall"
    @Environment(\.componentRegistry) private var componentRegistry
    
    let directive: Directive
    let children: [Component]
    
    var name: String {
        directive["name"] ?? ""
    }
    
    var props: [String: Any] {
        directive.props["props"] as? [String: Any] ?? [:]
    }
    
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        self.directive = directive
        self.children = directive.children.compactMap(makeComponent(_:))
    }
}

extension CallComponent: View {
    
    var body: some View {
        if let resolved = componentRegistry.makeComponent(name, props: props, children: children) {
            resolved
        } else {
            ForEach(children.indices, id: \.self) { index in
                ComponentView(children[index])
            }
        }
    }
}
