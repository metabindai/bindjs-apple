import SwiftUI

extension AnyView: ComponentProtocol {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.defaultVisit(self)
    }
}

struct NativeFunction: Callable {
    
    var enclosedContext: ComponentContext?
    
    public func accept<V>(_ visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.defaultVisit(self)
    }
    
    let body: (_ arguments: [String: ComponentProtocol], _ context: ComponentContext) -> ComponentProtocol
    
    func callAsFunction(_ arguments: [String : any ComponentProtocol], context: ComponentContext) -> any ComponentProtocol {
        body(arguments, context)
    }
}
