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
            newContext.define(key, value)
            context = newContext
        }
    }
    
    public func defaults<Content: View>(_ key: String, @ViewBuilder _ content: @escaping (_ props: [String: Component], _ children: [Component]) -> Content) -> some View {
        transformEnvironment(\.componentContext) { context in
            let newContext = ComponentContext(parent: context)
            let opaque: ([String: Component], [Component]) -> AnyView = {
                AnyView(content($0, $1))
            }
            newContext.define(key, OpaqueFunction(function: opaque))
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

/// A wrapper around a Swift function
struct OpaqueFunction: Callable {
    let function: ([String: Component], [Component]) -> AnyView
    
    func accept<Visitor>(_ visitor: inout Visitor) -> Visitor.Result where Visitor : ComponentVisitor {
        visitor.defaultVisit(self)
    }
    
    func callAsFunction(_ arguments: [String : any Component]) -> any Component {
        let children = arguments["children"]?.arrayValue ?? []
        return function(arguments, children)
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
    @State var evaluated: Component = []
    @StateObject var context = ComponentContext()
    
    public init(_ component: Component) {
        self.component = component
    }
    
    public var body: some View {
        ComponentView(evaluated)
            .task(id: component.jsonString) {
                context.parent = parentContext
                context.objectWillChange.send()
                evaluated = component.evaluate(context)
            }
    }
}

public struct ComponentView: View {
    
    let component: Component
    
    public init(_ component: Component) {
        self.component = component
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
            EmptyView()
        case let anyView as AnyView:
            anyView
        default:
            Text("No View: \(type(of: component))")
        }
    }
}
