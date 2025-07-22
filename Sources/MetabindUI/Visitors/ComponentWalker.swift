public protocol ComponentWalker: ComponentVisitor where Result == Void {
    
}

public extension ComponentWalker {
    mutating func descendInto(_ component: Component) {
        let mirror = Mirror(reflecting: component)
        for child in mirror.children {
            if let component = child.value as? Component {
                visit(component)
            } else if let components = child.value as? [Component] {
                for component in components {
                    visit(component)
                }
            } else if let optionalComponent = child.value as? Optional<Component>,
                      let component = optionalComponent {
                visit(component)
            }
        }
    }
}
