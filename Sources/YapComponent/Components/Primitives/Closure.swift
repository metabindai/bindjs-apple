protocol Callable: ComponentProtocol {
    var enclosedContext: ComponentContext? { get }
    func callAsFunction(_ arguments: [String: ComponentProtocol], context: ComponentContext) -> ComponentProtocol
}

public struct Closure: Callable {
    let props: [String: ComponentProtocol]
    let body: ComponentProtocol
    var enclosedContext: ComponentContext?
    
    public init(props: [String : ComponentProtocol], body: ComponentProtocol, enclosedContext: ComponentContext? = nil) {
        self.props = props
        self.body = body
        self.enclosedContext = enclosedContext
    }
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitClosure(self)
    }
    
    func bind(_ context: ComponentContext) -> Self {
        var copy = self
        copy.enclosedContext = context
        return copy
    }
    
    func callAsFunction(_ arguments: [String: ComponentProtocol], context: ComponentContext) -> ComponentProtocol {
        let newContext = ComponentContext(parent: context)
        
        for (key, value) in props {
            newContext.define(key, value.evaluate(enclosedContext!))
        }
        
        for (key, value) in arguments {
            newContext.define(key, value)
        }
        
        return body.evaluate(newContext)
    }
}

extension Evaluator {
    mutating func visitClosure(_ closure: Closure) -> any ComponentProtocol {
        closure.bind(context)
    }
}
