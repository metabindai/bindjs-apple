import SwiftUI
import JavaScriptCore

struct ComponentButtonStyle: ButtonStyle {
    
    @Environment(\.componentRuntime) var componentRuntime
    
    let name: String
    
    func makeButtonFunction() -> JSValue {
        let function = componentRuntime.value.context.evaluateScript("""
            makeComponent(() => ({ type: "\(name)" }))
        """)
        return function!
    }
    
    func makeBody(configuration: Configuration) -> some View {
        componentRuntime.view(name, arguments: ["label": makeButtonFunction(), "isPressed": configuration.isPressed])
            .transformEnvironment(\.componentContext) { context in
                context.define(name, AnyView(configuration.label))
            }
    }
}

