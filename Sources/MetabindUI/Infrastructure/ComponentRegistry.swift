import SwiftUI

struct ComponentRegistry {
    var components: [String: ([String: Any], [Component]) -> AnyView] = [:]
    
    mutating func register<C: View>(_ name: String, @ViewBuilder build: @escaping (_ props: [String: Any], _ children: [Component]) -> C) {
        components[name] = {
            AnyView(build($0, $1))
        }
    }
    
    func makeComponent(_ name: String, props: [String: Any], children: [Component], componentContext: ComponentContext) -> AnyView? {
        guard let builder = components[name] else { return nil }
        return AnyView(
            builder(props, children)
                .environmentObject(componentContext)
        )
    }
}

extension EnvironmentValues {
    @Entry var componentRegistry = ComponentRegistry()
}

extension View {
    public func component<R: ComponentRepresentable>(_ component: R) -> some View {
        transformEnvironment(\.componentRegistry) { registry in
            registry.register(component.name) { props, children in
                component.makeView(context: .init(children: children, props: props))
                    .environmentObject(ComponentContext())
            }
        }
    }
}

