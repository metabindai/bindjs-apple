import SwiftUI

public struct ChartSelectionComponent: Component {
    public static var directiveName: String = "chartSelection"

    public var binding: PieSelectionBinding
}

extension ChartSelectionComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        binding = PieSelectionBinding(from: directive)
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartSelection(self)
    }
}

extension ChartSelectionComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content
    }
}

public struct ChartXSelectionComponent: Component {
    public static var directiveName: String = "chartXSelection"

    public var binding: ChartSelectionBinding
}

extension ChartXSelectionComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        binding = ChartSelectionBinding(from: directive)
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartXSelection(self)
    }
}

extension ChartXSelectionComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(ChartXSelectionRuntimeApplier(binding: binding))
    }
}

public struct ChartYSelectionComponent: Component {
    public static var directiveName: String = "chartYSelection"

    public var binding: ChartSelectionBinding
}

extension ChartYSelectionComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        binding = ChartSelectionBinding(from: directive)
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartYSelection(self)
    }
}

extension ChartYSelectionComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(ChartYSelectionRuntimeApplier(binding: binding))
    }
}

private struct ChartXSelectionRuntimeApplier: ViewModifier {
    @EnvironmentObject private var context: BindJSContext
    let binding: ChartSelectionBinding

    func body(content: Content) -> some View {
        content.modifier(ChartXSelectionApplier(binding: binding, context: context))
    }
}

private struct ChartYSelectionRuntimeApplier: ViewModifier {
    @EnvironmentObject private var context: BindJSContext
    let binding: ChartSelectionBinding

    func body(content: Content) -> some View {
        content.modifier(ChartYSelectionApplier(binding: binding, context: context))
    }
}

extension ChartSelectionBinding {
    init(from directive: Directive) {
        self.init(
            value: ChartValue(directive.props["value"]),
            onChangeId: directive["onChangeId"]
        )
    }
}

extension PieSelectionBinding {
    init(from directive: Directive) {
        self.init(
            value: directive.props["value"] as? String,
            onChangeId: directive["onChangeId"]
        )
    }
}
