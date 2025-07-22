import SwiftUI

public struct CallComponent: Component {
    public static var directiveName: String = "ComponentCall"
    @Environment(\.componentRegistry) private var componentRegistry
    
    public let directive: Directive
    public let children: [Component]
    
    var name: String {
        directive["name"] ?? ""
    }
    
    var props: [String: Any] {
        directive.props["props"] as? [String: Any] ?? [:]
    }
    
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        self.directive = directive
        self.children = directive.children.compactMap(makeComponent(_:))
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitCall(self)
    }
}

extension CallComponent: View {
    
    public var body: some View {
        if let resolved = componentRegistry.makeComponent(name, props: props, children: children) {
            resolved
        } else {
            ForEach(children.indices, id: \.self) { index in
                ComponentView(children[index])
            }
        }
    }
}
