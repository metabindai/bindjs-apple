import SwiftUI

public protocol ComponentRepresentable {
    associatedtype Body: View
    
    var name: String { get }
    func makeView(context: Self.Context) -> Self.Body
    
    typealias Context = ComponentRepresentableContext
}

public struct ComponentRepresentableContext {
    public let children: [Component]
    public let props: [String: Any]
    
    public var content: some View {
        ForEach(children.indices, id: \.self) { index in
            ComponentView(children[index])
        }
    }
}
