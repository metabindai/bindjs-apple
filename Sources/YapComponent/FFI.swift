/// A wrapper around a Swift function
public struct OpaqueFunction: Callable {
    let body: ([String: Component], [Component], ComponentContext) -> Component
    
    public init(body: @escaping ([String : Component], [Component], ComponentContext) -> Component) {
        self.body = body
    }
    
    public func accept<Visitor>(_ visitor: inout Visitor) -> Visitor.Result where Visitor : ComponentVisitor {
        visitor.defaultVisit(self)
    }
    
    public func callAsFunction(_ arguments: [String : any Component], _ callingContext: ComponentContext) -> any Component {
        let children = arguments["children"]?.arrayValue ?? []
        return body(arguments, children, callingContext)
    }
}
