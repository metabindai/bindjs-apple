import SwiftUI

public struct PlaceholderComponent: Component {
    public static var directiveName: String = "Placeholder"
    @Environment(\.componentCall) private var enclosingCall
    @Environment(\.componentRegistry) private var componentRegistry
    @EnvironmentObject private var componentContext: ComponentContext
    
    let name: String
}

extension PlaceholderComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.name = directive["name"] ?? ""
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitPlaceholder(self)
    }
}

extension PlaceholderComponent: View {
    public var body: some View {
        if let enclosingCall {
            let _ = {
                print(enclosingCall)
            }()
        }
        defaultPlaceholder
    }
    
    var defaultPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
    }
}
