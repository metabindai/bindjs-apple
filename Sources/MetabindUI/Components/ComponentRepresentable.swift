import SwiftUI

public protocol ComponentRepresentable {
    associatedtype Body: View
    
    var name: String { get }
    @ViewBuilder
    func makeView(context: Self.Context) -> Self.Body
    
    typealias Context = ComponentRepresentableContext
}

public struct ComponentRepresentableContext {
    public let children: [Component]
    public let props: [String: Any]
    public let componentContext: ComponentContext?
    
    public init(children: [Component], props: [String: Any], componentContext: ComponentContext? = nil) {
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
