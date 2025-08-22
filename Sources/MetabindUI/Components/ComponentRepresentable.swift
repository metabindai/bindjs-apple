import SwiftUI

public protocol DefaultInitializable {
    init()
}

public protocol ComponentRepresentable: DefaultInitializable {
    associatedtype Body: View
    
    static var name: String { get }
    @ViewBuilder
    static func makeView(context: Self.Context) -> Self.Body
    
    typealias Context = ComponentRepresentableContext
}

public struct ComponentRepresentableContext {
    public let children: [Component]
    public let props: [String: Any]
    public let componentContext: ComponentContext
    public let environmentValues: EnvironmentValues
    
    public init(children: [Component], props: [String: Any], componentContext: ComponentContext, environmentValues: EnvironmentValues) {
        self.children = children
        self.props = props
        self.componentContext = componentContext
        self.environmentValues = environmentValues
    }
    
    public var content: some View {
        ForEach(children.indices, id: \.self) { index in
            ComponentView(children[index])
        }
    }
}
