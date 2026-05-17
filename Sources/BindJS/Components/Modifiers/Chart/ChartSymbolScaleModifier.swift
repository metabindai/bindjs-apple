import SwiftUI

public struct ChartSymbolScaleComponent: Component {
    public static var directiveName: String = "chartSymbolScale"

    public var scale: [String: ChartMarkStyle.SymbolName]
}

extension ChartSymbolScaleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        scale = directive.props.compactMapValues { value in
            guard let raw = value as? String else { return nil }
            return ChartMarkStyle.SymbolName(rawValue: raw)
        }
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChartSymbolScale(self)
    }
}

extension ChartSymbolScaleComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(ChartSymbolScaleApplier(scale: scale))
    }
}
