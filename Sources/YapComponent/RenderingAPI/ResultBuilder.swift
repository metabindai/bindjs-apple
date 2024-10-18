@resultBuilder
public struct ComponentBuilder {
    public static func buildBlock(_ components: ComponentProtocol...) -> [ComponentProtocol] {
        components
    }
}

extension ForEachComponent {
    public init(_ data: ComponentProtocol, variable: String, @ComponentBuilder _ content: () -> [ComponentProtocol]) {
        self.data = data
        self.content = content()
        self.variable = variable
    }
}

extension ConditionalComponent {
    public init(_ condition: ComponentProtocol, @ComponentBuilder then thenContent: () -> [ComponentProtocol], @ComponentBuilder else elseContent: () -> [ComponentProtocol]) {
        self.condition = condition
        self.thenContent = thenContent()
        self.elseContent = elseContent()
    }
    
    public init(_ condition: ComponentProtocol, @ComponentBuilder then thenContent: () -> [ComponentProtocol]) {
        self.condition = condition
        self.thenContent = thenContent()
        self.elseContent = EmptyComponent()
    }
}

extension VStackComponent {
    public init(alignment: HorizontalAlignmentComponent = .center, spacing: Double? = nil, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.alignment = alignment
        self.spacing = spacing
        self.children = children()
    }
}

extension HStackComponent {
    public init(alignment: VerticalAlignmentComponent = .center, spacing: Double? = nil, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.alignment = alignment
        self.spacing = spacing
        self.children = children()
    }
}

extension ZStackComponent {
    public init(alignment: AlignmentComponent = .init(), @ComponentBuilder content: () -> [ComponentProtocol]) {
        self.alignment = alignment
        self.content = content()
    }
}

extension ScrollViewComponent {
    public init(axes: AxisSetComponent = .vertical, showsIndicators: Bool = true, @ComponentBuilder content: () -> [ComponentProtocol]) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
}

extension ListComponent {
    public init(@ComponentBuilder content: () -> [ComponentProtocol]) {
        self.content = content()
    }
}

extension Component {
    public init(_ type: String, props: [String: ComponentProtocol] = [:], @ComponentBuilder _ children: () -> [ComponentProtocol]) {
        self.type = type
        self.props = props
        self.children = children()
    }
}

extension ButtonComponent {
    public init(action: String, @ComponentBuilder label: () -> ComponentProtocol) {
        self.action = action
        self.label = label()
    }
}

extension Closure {
    public init(parameters: [String: ComponentProtocol], @ComponentBuilder body: () -> ComponentProtocol) {
        self.props = parameters
        self.body = body()
    }
}

extension NavigationLinkComponent {
    public init(value: String, @ComponentBuilder label: () -> ComponentProtocol) {
        self.value = value
        self.label = label()
    }
}
