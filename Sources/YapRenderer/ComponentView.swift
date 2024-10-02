import SwiftUI
import YapComponent

extension Directive: View {
    
    public var body: some View {
        switch type {
        // Shapes
        case ShapeView.Name.self: ShapeView(self)
        // Leaf Views
        case LeafView.Name.self: LeafView(self)
        // Containers
        case ContainerView.Name.self: ContainerView(self)
        // Modifiers
        case ModifierView.Name.self: ModifierView(self)
        default:
            ComponentView(children)
        }
    }
}

public struct RootComponentView: View {
    let component: Component
    @State var evaluated: Component = []
    @StateObject var context = ComponentContext()
    
    public init(_ component: Component) {
        self.component = component
    }
    
    public var body: some View {
        ComponentView(evaluated)
            .task(id: component.jsonString) {
                evaluated = component.evaluate(context)
                context.objectWillChange.send()
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
            directive
        case let array as [Component]:
            if array.isEmpty {
                Color.clear.frame(width: 0, height: 0)
            } else {
                ForEach(array.indices, id: \.self) { index in
                    ComponentView(array[index])
                }
            }
        case is EmptyComponent:
            EmptyView()
        default:
            Text("No View: \(type(of: component))")
        }
    }
}
