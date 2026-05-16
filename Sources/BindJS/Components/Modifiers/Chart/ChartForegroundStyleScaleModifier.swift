import Charts
import SwiftUI

public struct ChartForegroundStyleScaleComponent: Component {
    public static var directiveName: String = "chartForegroundStyleScale"

    public var scale: [String: String]
}

extension ChartForegroundStyleScaleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        scale = directive.props.compactMapValues { value in
            switch value {
            case let string as String:
                return string
            case let colorDirective as Directive:
                return ColorComponent(from: colorDirective)?.chartColorString
            default:
                return nil
            }
        }
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartForegroundStyleScale(self)
    }
}

extension ChartForegroundStyleScaleComponent: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        if scale.isEmpty {
            content
        } else {
            let ordered = scale.keys.sorted()
            content.chartForegroundStyleScale(
                domain: ordered,
                range: ordered.map { Color.chartColor(named: scale[$0] ?? $0) }
            )
        }
    }
}
