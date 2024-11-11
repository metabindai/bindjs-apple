import SwiftUI

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

extension VStackComponent {
    public init(alignment: HorizontalAlignment = .center, spacing: Double? = nil, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.alignment = alignment.string
        self.spacing = spacing
        self.children = children()
    }
}

extension HStackComponent {
    public init(alignment: VerticalAlignment = .center, spacing: Double? = nil, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.alignment = alignment.string
        self.spacing = spacing
        self.children = children()
    }
}

extension ZStackComponent {
    public init(alignment: Alignment = .center, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.alignment = String(describing: alignment)
        self.children = children()
    }
}

extension ScrollViewComponent {
    public init(axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ComponentBuilder children: () -> [ComponentProtocol]) {
        self.axes = axes.string
        self.showsIndicators = showsIndicators
        self.children = children()
    }
}

extension ListComponent {
    public init(@ComponentBuilder children: () -> [ComponentProtocol]) {
        self.children = children()
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

extension NavigationLinkComponent {
    public init(value: String, @ComponentBuilder label: () -> ComponentProtocol) {
        self.value = value
        self.label = label()
    }
}
