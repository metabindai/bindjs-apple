import SwiftUI

public struct Defaults: ComponentProtocol {
    let constants: [String: ComponentProtocol]
    let content: ComponentProtocol
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDefaults(self)
    }
}

struct DefaultsView: View {
    
    let defaults: Defaults
    
    init(_ defaults: Defaults) {
        self.defaults = defaults
    }
    
    var body: some View {
        ComponentView(defaults.content)
            .transformEnvironment(\.componentContext) { context in
                let newContext = ComponentContext(parent: context)
                
                for (key, value) in defaults.constants {
                    newContext.define(key, value.evaluate(context))
                }
                
                context = newContext
            }
    }
}

extension Evaluator {
    
    mutating func visitDefaults(_ defaults: Defaults) -> any ComponentProtocol {
        let newContext = ComponentContext(parent: context)
        for (key, value) in defaults.constants {
            newContext.define(key, value.evaluate(context))
        }
        return defaults.content.evaluate(newContext)
    }
}
