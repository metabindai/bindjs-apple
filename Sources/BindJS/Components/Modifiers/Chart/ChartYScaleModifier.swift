import Charts
import SwiftUI

public struct ChartYScaleComponent: Component {
    public static var directiveName: String = "chartYScale"

    public var scale: ChartScaleOption
}

extension ChartYScaleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        scale = ChartScaleOption(from: directive)
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartYScale(self)
    }
}

extension ChartYScaleComponent: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        if let range = scale.domain?.numericRange {
            content.chartYScale(domain: range)
        } else if let categories = scale.domain?.stringDomain {
            content.chartYScale(domain: categories)
        } else {
            content
        }
    }
}
