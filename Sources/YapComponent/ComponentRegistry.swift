import SwiftUI

struct ComponentRegistry {
    var components: [String: ([String: Any], [Component]) -> AnyView] = [:]
    
    mutating func register<C: View>(_ name: String, @ViewBuilder build: @escaping (_ props: [String: Any], _ children: [Component]) -> C) {
        components[name] = {
            AnyView(build($0, $1))
        }
    }
    
    func makeComponent(_ name: String, props: [String: Any], children: [Component]) -> AnyView? {
        guard let builder = components[name] else { return nil }
        return builder(props, children)
    }
}

extension EnvironmentValues {
    @Entry var componentRegistry = ComponentRegistry()
}

extension View {
    public func component<C: View>(_ name: String, @ViewBuilder build: @escaping (_ props: [String: Any], _ content: [Component]) -> C) -> some View {
        transformEnvironment(\.componentRegistry) { registry in
            registry.register(name, build: build)
        }
    }
}
