import SwiftUI


extension View {
    public func defaults(_ key: String, _ value: any ComponentProtocol) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            newContext.define(key, value)
            context = newContext
        }
    }
    
    public func defaults<Content: View>(_ key: String, @ViewBuilder _ content: @escaping (_ arguments: [String: ComponentProtocol], _ context: ComponentContext) -> Content) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            
            
            let nativeFunction = NativeFunction(enclosedContext: context) { arguments, context in
                AnyView(content(arguments, context))
            }
            
            newContext.define(key, nativeFunction)
            
            context = newContext
        }
    }
}
