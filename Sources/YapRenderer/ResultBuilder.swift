import YapComponent

@resultBuilder
public struct ComponentBuilder {
    public static func buildBlock(_ components: Component...) -> Component {
        switch components.count {
        case 0: EmptyComponent()
        case 1: components[0]
        default: components
        }
    }
}

extension Variable {
    public init(_ name: String) {
        self.init(name: name)
    }
}

extension Directive {
    public init(_ type: String, props: [String: Component] = [:], @ComponentBuilder children build: () -> Component = {[]}) {
        self.init(type: type, props: props, children: build().arrayValue)
    }
    
    public init(_ type: String, _ _0: Component, @ComponentBuilder children build: () -> Component = {[]}) {
        if let props = _0 as? [String: Component] {
            self.init(type: type, props: props, children: build().arrayValue)
        } else {
            self.init(type: type, props: ["_0": _0], children: build().arrayValue)
        }
    }
}

public func Group(@ComponentBuilder content: () -> Component) -> Component {
    Directive(type: "Group", children: content().arrayValue)
}

extension ConditionalComponent {
    public init(_ condition: Component, @ComponentBuilder then thenContent: () -> Component, @ComponentBuilder else elseContent: () -> Component) {
        self.init(condition: condition, then: thenContent(), else: elseContent())
    }
    
    public init(_ condition: Component, @ComponentBuilder then thenContent: () -> Component) {
        self.init(condition: condition, then: thenContent(), else: nil)
    }
}

public typealias If = ConditionalComponent

extension Closure {
    public init(parameters: [String: Component] = [:], @ComponentBuilder build: () -> Component) {
        self.init(parameters: parameters, content: build())
    }
}

extension ForEachComponent {
    public init(_ data: Component, @ComponentBuilder content: () -> Component) {
        self.init(data: data, content: content())
    }
}

extension Defaults {
    public init(_ key: String, _ value: Component, @ComponentBuilder content: () -> Component) {
        self.init(constants: [key: value], content: content())
    }
}
