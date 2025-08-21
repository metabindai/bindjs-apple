import SwiftUI

struct ComponentRegistry {
    var components: [String: () -> any ComponentRepresentable] = [:]
    
    func makeComponent(_ name: String, props: [String: Any], children: [Component], componentContext: ComponentContext) -> AnyView? {
        guard let builder = components[name] else { return nil }
        let c = ComponentRepresentableContext(
            children: children,
            props: props,
            componentContext: componentContext
        )
        return AnyView(builder().makeView(context: c))
    }
}

extension EnvironmentValues {
    @Entry var componentRegistry = ComponentRegistry()
}

extension View {
    public func withComponent<R: ComponentRepresentable>(_ component: R.Type) -> some View {
        transformEnvironment(\.componentRegistry) { registry in
            registry.components[R.name] = R.init
        }
    }
}

