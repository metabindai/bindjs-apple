import SwiftUI

public struct Component: ComponentProtocol {
    let type: String
    var props: [String: ComponentProtocol] = [:]
    var children: [ComponentProtocol] {
        get { props["children"]?.arrayValue ?? [] }
        set { props["children"] = newValue }
    }
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitComponent(self)
    }
}

extension Component {
    public init(_ type: String, props: [String: ComponentProtocol] = [:], children: [ComponentProtocol] = []) {
        self.type = type
        self.props = props
        self.children = children
    }
}

extension Component {
    public init<T: AutomaticComponentConvertible>(_: T.Type, _ props: [PartialKeyPath<T>: ComponentProtocol]) {
        self.type = T.componentName
        for (keyPath, value) in props {
            if let key = T.keyPaths.first(where: { $0.1 == keyPath })?.0 {
                self.props[key] = value
            }
        }
    }
}

struct CustomView: View {
    @Environment(\.componentContext) private var context
    let component: Component
    
    init(_ component: Component) {
        self.component = component
    }
    
    var body: some View {
        if let definition = context.get(component.type) as? Callable {
            ComponentView(definition.callAsFunction(component.props, context: context))
        } else {
            ComponentView(component.children)
        }
    }
}

extension Evaluator {
    
    mutating func visitComponent(_ component: Component) -> any ComponentProtocol {
        let props = component.props.mapValues { $0.accept(&self) }
        
        if let definition = context.get(component.type) as? Callable {
            return definition.callAsFunction(props, context: context)
        }
        
        return Component(type: component.type, props: props)
    }
}
