import SwiftUI

public struct ConditionalComponent: ComponentProtocol {
    let condition: ComponentProtocol
    let thenContent: ComponentProtocol
    let elseContent: ComponentProtocol
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitConditional(self)
    }
}

struct ConditionalView: View {
    @Environment(\.componentContext) private var context
    let conditionalComponent: ConditionalComponent
    
    init(_ conditionalComponent: ConditionalComponent) {
        self.conditionalComponent = conditionalComponent
    }
    
    var body: some View {
        if conditionalComponent.condition.evaluate(context).isTruthy {
            ComponentView(conditionalComponent.thenContent)
        } else {
            ComponentView(conditionalComponent.elseContent)
        }
    }
}

extension Evaluator {
    mutating func visitConditional(_ conditional: ConditionalComponent) -> any ComponentProtocol {
        if conditional.condition.accept(&self).isTruthy {
            return conditional.thenContent.accept(&self)
        } else {
            return conditional.elseContent.accept(&self)
        }
    }
}
