import SwiftUI

struct ComponentRegistry {
    var components: [String: (ComponentRepresentableContext) -> AnyView] = [:]
    
    func makeComponent(_ name: String, props: [String: Any], children: [Component], componentContext: ComponentContext) -> AnyView? {
        guard let builder = components[name] else { return nil }
        let context = ComponentRepresentableContext(
            children: children,
            props: props,
            componentContext: componentContext
        )
        return builder(context)
    }
}

extension EnvironmentValues {
    @Entry var componentRegistry = ComponentRegistry()
}

extension View {
    public func withComponent<R: ComponentRepresentable>(_ component: R.Type) -> some View {
        transformEnvironment(\.componentRegistry) { registry in
            registry.components[R.name] = { context in
                var instance = R.init()
                instance.context = context
                return AnyView(instance)
            }
        }
    }
}
