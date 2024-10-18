import SwiftUI

public struct Variable: ComponentProtocol {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitVariable(self)
    }
}

struct VariableView: View {
    @Environment(\.componentContext) private var context
    let variable: Variable
    
    init(_ variable: Variable) {
        self.variable = variable
    }
    
    var body: some View {
        ComponentView(context.get(variable.name) ?? EmptyComponent())
    }
}

extension Evaluator {
    
    mutating func visitVariable(_ variable: Variable) -> any ComponentProtocol {
        context.get(variable.name) ?? EmptyComponent()
    }
}
