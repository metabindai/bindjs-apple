import SwiftUI

public struct ForEachComponent: ComponentProtocol {
    let variable: String
    let data: ComponentProtocol
    let content: ComponentProtocol
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitForEach(self)
    }
    
    public init(variable: String, data: ComponentProtocol, content: ComponentProtocol) {
        self.variable = variable
        self.data = data
        self.content = content
    }
}

struct ForEachView: View {
    @Environment(\.componentContext) private var context
    let forEachComponent: ForEachComponent
    
    init(_ forEachComponent: ForEachComponent) {
        self.forEachComponent = forEachComponent
    }
    
    var body: some View {
        let array = forEachComponent.data.evaluate(context).arrayValue
        ForEach(array.indices, id: \.self) { index in
            ComponentView(forEachComponent.content)
                .transformEnvironment(\.componentContext) { context in
                    let newContext = ComponentContext(parent: context)
                    newContext.define("index", index)
                    newContext.define("element", array[index])
                    newContext.define(forEachComponent.variable, array[index])
                    
                    context = newContext
                }
        }
    }
}

extension Evaluator {
    mutating func visitForEach(_ forEach: ForEachComponent) -> any ComponentProtocol {
        let array = forEach.data.accept(&self).arrayValue
        var result: [ComponentProtocol] = []
        for (index, element) in array.enumerated() {
            let newContext = ComponentContext(parent: context)
            newContext.define("index", index)
            newContext.define("element", element)
            newContext.define(forEach.variable, element)
            result.append(forEach.content.evaluate(newContext))
        }
        return result
    }
}
