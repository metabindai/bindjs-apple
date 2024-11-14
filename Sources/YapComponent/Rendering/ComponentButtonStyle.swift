import SwiftUI
import JavaScriptCore

struct ComponentButtonStyle: ButtonStyle {
    @Environment(\.componentRuntime) private var componentRuntime
    @State private var isPressedView: AnyView?
    @State private var isNotPressedView: AnyView?
    
    let name: String
    
    private let uuid: String = UUID().uuidString
    
    private func makeLabel() -> JSValue {
        let function = componentRuntime.value.context.evaluateScript("""
            makeComponent(() => ({ type: "\(uuid)" }))
        """)
        return function!
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Calling this is calling a view, returning an AST which can be rendered.
            componentRuntime.view(name, arguments: [
                "label": makeLabel(),
                "isPressed": configuration.isPressed
            ])
            
            // But we first place the swift ui view in the environment so that it can get
            // rendered by the CustomView in its body.
            .transformEnvironment(\.componentEnvironment) { environment in
                environment[uuid] = AnyView(configuration.label)
            }
        }
    }
}
