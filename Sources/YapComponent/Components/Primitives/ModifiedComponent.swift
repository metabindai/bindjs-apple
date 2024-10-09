import SwiftUI

public struct ModifiedComponent: ComponentProtocol {
    var content: ComponentProtocol = EmptyComponent()
    var modifier: ComponentProtocol = EmptyComponent()
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitModifiedComponent(self)
    }
}

struct ModifiedComponentView: View {
    let modified: ModifiedComponent
    
    init(_ modified: ModifiedComponent) {
        self.modified = modified
    }
    
    var body: some View {
        ComponentView(modified.content)
            .modifier(ComponentViewModifier(modified.modifier))
    }
}

extension Evaluator {
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> any ComponentProtocol {
        let newContext = ComponentContext(parent: context)
        let modifier = modifiedComponent.modifier.evaluate(newContext)
        let content = modifiedComponent.content.evaluate(newContext)
        return content.modifier(modifier)
    }
}
