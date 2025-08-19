import SwiftUI

struct ComponentRegistry {
    var components: [String: ([String: Any], [Component], ComponentContext) -> AnyView] = [:]
    
    mutating func register<C: View>(_ name: String, @ViewBuilder build: @escaping (_ props: [String: Any], _ children: [Component], _ componentContext: ComponentContext) -> C) {
        components[name] = { props, children, context in
            AnyView(build(props, children, context))
        }
    }
    
    func makeComponent(_ name: String, props: [String: Any], children: [Component], componentContext: ComponentContext) -> AnyView? {
        guard let builder = components[name] else { return nil }
        return AnyView(
            builder(props, children, componentContext)
        )
    }
}

extension EnvironmentValues {
    @Entry var componentRegistry = ComponentRegistry()
}

extension View {
    public func withComponent<R: ComponentRepresentable>(_ component: R) -> some View {
        transformEnvironment(\.componentRegistry) { registry in
            registry.register(component.name) { props, children, componentContext in
                component.makeView(context: .init(
                    children: children,
                    props: props,
                    componentContext: componentContext
                ))
            }
        }
    }
}

