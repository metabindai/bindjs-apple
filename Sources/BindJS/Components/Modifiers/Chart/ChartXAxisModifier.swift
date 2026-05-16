import Charts
import SwiftUI

public struct ChartXAxisComponent: Component {
    public static var directiveName: String = "chartXAxis"

    public var options: ChartAxisOption
}

extension ChartXAxisComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        options = ChartAxisOption(from: directive)
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartXAxis(self)
    }
}

extension ChartXAxisComponent: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        if options.hidden {
            content.chartXAxis(.hidden)
        } else {
            content.chartXAxis(.automatic)
        }
    }
}
