import SwiftUI
import YapComponent

struct DirectiveView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    public var body: some View {
        switch directive.type {
        // Shapes
        case ShapeView.Name.self: ShapeView(directive)
        // Leaf Views
        case LeafView.Name.self: LeafView(directive)
        // Containers
        case ContainerView.Name.self: ContainerView(directive)
        // Modifiers
        case ModifierView.Name.self: ModifierView(directive)
        default:
            ComponentView(directive.children)
        }
    }
}


extension View {
    public func defaults(_ key: String, _ value: Component) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            newContext.define(key, value.evaluate(context))
            context = newContext
        }
    }
    
    public func defaults(_ keysAndValues: [String: Component]) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            for (key, value) in keysAndValues {
                newContext.define(key, value.evaluate(context))
            }
            context = newContext
        }
    }
    
    public func defaults<Content: View>(_ key: String, @ViewBuilder _ content: @escaping (_ props: [String: Component], _ children: [Component]) -> Content) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            let opaque: ([String: Component], [Component], ComponentContext) -> AnyView = { props, children, _ in
                AnyView(content(props, children))
            }
            newContext.define(key, OpaqueFunction(body: opaque))
            context = newContext
        }
    }
    
    public func defaults<Result: Component>(_ key: String, body: @escaping (_ props: [String: Component], _ children: [Component], _ context: ComponentContext) -> Result) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            newContext.define(key, OpaqueFunction(body: body))
            context = newContext
        }
    }
    
    public func defaults(_ key: String, body: @escaping (_ props: [String: Component], _ children: [Component], _ context: ComponentContext) -> Void) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            newContext.define(key, OpaqueFunction(body: {
                body($0, $1, $2)
                return EmptyComponent()
            }))
            context = newContext
        }
    }
    
    public func transformDefaults(_ transform: @escaping (_ context: ComponentContext) -> Void) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            transform(newContext)
            context = newContext
        }
    }
}

extension AnyView: Component {
    nonisolated public func accept<Visitor>(_ visitor: inout Visitor) -> Visitor.Result where Visitor : ComponentVisitor {
        visitor.defaultVisit(self)
    }
}

struct ComponentEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: ComponentContext = .init()
}

extension EnvironmentValues {
    public var componentContext: ComponentContext {
        get {
            self[ComponentEnvironmentKey.self]
        }
        set {
            self[ComponentEnvironmentKey.self] = newValue
        }
    }
}

public struct RootComponentView: View {
    @Environment(\.componentContext) var parentContext
    let component: Component
    @State var evaluated: AnyComponent = .empty
    @StateObject var context = ComponentContext()
    
    public init(_ component: Component) {
        self.component = component
    }
    
    public func evaluate() {
        context.parent = parentContext
        evaluated = component.evaluate(context).erasedToAnyComponent
    }
    
    public var body: some View {
        ComponentView(evaluated)
            .task(id: component.jsonString) {
                evaluate()
            }
            .onReceive(context.objectWillChange) { _ in
                evaluate()
            }
    }
}

public struct ComponentView: View, @preconcurrency Equatable {
    
    let component: AnyComponent
    
    public init(_ component: Component) {
        self.component = component.erasedToAnyComponent
    }
    
    public var body: some View {
        switch component.unerased {
        case let directive as Directive:
            DirectiveView(directive)
        case let array as [Component]:
            if array.isEmpty {
                Color.clear.frame(width: 0, height: 0)
            } else {
                ForEach(array.indices, id: \.self) { index in
                    ComponentView(array[index])
                }
            }
        case let string as String:
            Text(string)
        case is EmptyComponent:
            Color.clear.frame(width: 0, height: 0).hidden()
        case let anyView as AnyView:
            anyView
        case let value:
            if let anyView = AnyView(_fromValue: value) {
                anyView
            } else {
                Text("No View: \(type(of: component))")
            }
        }
    }
    
    public static func == (lhs: ComponentView, rhs: ComponentView) -> Bool {
        lhs.component == rhs.component
    }
}
