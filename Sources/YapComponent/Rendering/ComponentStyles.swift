import SwiftUI
import JavaScriptCore

struct ComponentButtonStyle: ButtonStyle {
    @Environment(\.componentRuntime) private var componentRuntime
    
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

struct ComponentToggleStyle: ToggleStyle {
    @Environment(\.componentRuntime) private var componentRuntime
    
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
                "isOn": configuration.isOn
            ])
            
            // But we first place the swift ui view in the environment so that it can get
            // rendered by the CustomView in its body.
            .transformEnvironment(\.componentEnvironment) { environment in
                environment[uuid] = AnyView(configuration.label)
            }
        }
    }
}

struct ComponentLabelStyle: LabelStyle {
    @Environment(\.componentRuntime) private var componentRuntime
    
    let name: String
    
    private let iconId: String = UUID().uuidString
    private let titleId: String = UUID().uuidString
    
    private func makeLabel(_ id: String) -> JSValue {
        let function = componentRuntime.value.context.evaluateScript("""
            makeComponent(() => ({ type: "\(id)" }))
        """)
        return function!
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Calling this is calling a view, returning an AST which can be rendered.
            componentRuntime.view(name, arguments: [
                "icon": makeLabel(iconId),
                "title": makeLabel(titleId)
            ])
            
            // But we first place the swift ui view in the environment so that it can get
            // rendered by the CustomView in its body.
            .transformEnvironment(\.componentEnvironment) { environment in
                environment[iconId] = AnyView(configuration.icon)
                environment[titleId] = AnyView(configuration.title)
            }
        }
    }
}

struct ComponentProgressViewStyle: ProgressViewStyle {
    @Environment(\.componentRuntime) private var componentRuntime
    
    let name: String
    
    private let labelId: String = UUID().uuidString
    private let currentValueLabelId: String = UUID().uuidString
    
    private func makeLabel(_ id: String) -> JSValue {
        let function = componentRuntime.value.context.evaluateScript("""
            makeComponent(() => ({ type: "\(id)" }))
        """)
        return function!
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Calling this is calling a view, returning an AST which can be rendered.
            componentRuntime.view(name, arguments: [
                "label": makeLabel(labelId),
                "currentValueLabel": makeLabel(currentValueLabelId),
                "fractionCompleted": configuration.fractionCompleted
            ])
            
            // But we first place the swift ui view in the environment so that it can get
            // rendered by the CustomView in its body.
            .transformEnvironment(\.componentEnvironment) { environment in
                environment[labelId] = AnyView(configuration.label)
                environment[currentValueLabelId] = AnyView(configuration.currentValueLabel)
            }
        }
    }
}
