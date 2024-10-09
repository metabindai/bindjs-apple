import SwiftUI

struct ComponentButtonStyle: ButtonStyle {
    
    let name: String
    
    func makeBody(configuration: Configuration) -> some View {
        ComponentView(Component(name))
            .transformEnvironment(\.componentContext) { context in
                
                let newContext = ComponentContext(parent: context)
                
                newContext.define("configuration.label", AnyView(configuration.label))
                newContext.define("configuration.isPressed", configuration.isPressed)
                
                context = newContext
            }
    }
}

