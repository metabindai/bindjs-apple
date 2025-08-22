import SwiftUI

public protocol DefaultInitializable {
    init()
}

public protocol ComponentRepresentable: View, DefaultInitializable {
    static var name: String { get }
    
    var context: ComponentRepresentableContext { get set }
}

public struct ComponentRepresentableContext {
    public let children: [Component]
    public let props: [String: Any]
    public let componentContext: ComponentContext
    
    public init(children: [Component], props: [String: Any], componentContext: ComponentContext) {
        self.children = children
        self.props = props
        self.componentContext = componentContext
    }
    
    public var content: some View {
        ForEach(children.indices, id: \.self) { index in
            ComponentView(children[index])
        }
    }
}
