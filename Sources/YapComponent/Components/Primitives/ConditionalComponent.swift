import SwiftUI

public struct ConditionalComponent: ComponentProtocol {
    let condition: ComponentProtocol
    let thenContent: ComponentProtocol
    let elseContent: ComponentProtocol?
    
    public init(condition: ComponentProtocol, thenContent: ComponentProtocol, elseContent: ComponentProtocol?) {
        self.condition = condition
        self.thenContent = thenContent
        self.elseContent = elseContent
    }
    
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
        } else if let elseContent = conditionalComponent.elseContent {
            ComponentView(elseContent)
        }
    }
}

extension Evaluator {
    mutating func visitConditional(_ conditional: ConditionalComponent) -> any ComponentProtocol {
        if conditional.condition.accept(&self).isTruthy {
            return conditional.thenContent.accept(&self)
        } else if let elseContent = conditional.elseContent {
            return elseContent.accept(&self)
        } else {
            return EmptyComponent()
        }
    }
}
