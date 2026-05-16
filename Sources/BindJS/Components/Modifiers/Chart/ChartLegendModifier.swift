import Charts
import SwiftUI

public struct ChartLegendComponent: Component {
    public static var directiveName: String = "chartLegend"

    public var hidden: Bool
}

extension ChartLegendComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        if let visibility: String = directive["visibility"] ?? directive["position"] ?? directive.rawValue() {
            hidden = visibility == "hidden"
        } else {
            hidden = directive["hidden"] ?? false
        }
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartLegend(self)
    }
}

extension ChartLegendComponent: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        if hidden {
            content.chartLegend(.hidden)
        } else {
            content
        }
    }
}
