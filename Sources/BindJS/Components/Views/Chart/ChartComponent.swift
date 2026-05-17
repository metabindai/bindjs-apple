import Charts
import SwiftUI

public struct ChartComponent: Component {
    public static var directiveName: String = "Chart"

    public var children: [Component]
}

extension ChartComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        children = directive.children.compactMap { makeComponent($0) }
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitChart(self)
    }
}

extension ChartComponent: View {
    public var body: some View {
        ChartRenderedView(model: ChartCollector.collect(chart: self))
    }
}

struct ChartRenderedView: View {
    let model: ChartModel

    var body: some View {
        Chart {
            ChartMarkContent(model: model)
        }
        .modifier(ChartAxisApplier(axis: .x, options: model.axes.x))
        .modifier(ChartAxisApplier(axis: .y, options: model.axes.y))
        .modifier(ChartAxisLabelApplier(xLabel: model.axes.x?.label, yLabel: model.axes.y?.label))
        .modifier(ChartScaleApplier(scales: model.scales))
        .modifier(ChartLegendApplier(legend: model.legend))
        .modifier(ChartForegroundScaleApplier(scale: model.style.foregroundStyleScale))
        .modifier(ChartSymbolScaleApplier(scale: model.style.symbolScale))
        .modifier(ChartSelectionApplier(selection: model.selection))
        .accessibilityLabel(model.accessibility.label ?? "")
        .accessibilityHint(model.accessibility.description ?? "")
    }
}

enum ChartAxisKind {
    case x
    case y
}

struct ChartAxisApplier: ViewModifier {
    let axis: ChartAxisKind
    let options: ChartAxisOption?

    @ViewBuilder
    func body(content: Content) -> some View {
        switch axis {
        case .x:
            if options?.hidden == true {
                content.chartXAxis(.hidden)
            } else if let options, options.hasCustomAxisMarks {
                content.chartXAxis { chartAxisMarks(options, fallbackPosition: .bottom) }
            } else {
                content.chartXAxis(.automatic)
            }
        case .y:
            if options?.hidden == true {
                content.chartYAxis(.hidden)
            } else if let options, options.hasCustomAxisMarks {
                content.chartYAxis { chartAxisMarks(options, fallbackPosition: .leading) }
            } else {
                content.chartYAxis(.automatic)
            }
        }
    }
}

@AxisContentBuilder
private func chartAxisMarks(_ options: ChartAxisOption, fallbackPosition: AxisMarkPosition) -> some AxisContent {
    let position = options.axisMarkPosition ?? fallbackPosition
    if let numericValues = options.numericAxisValues {
        AxisMarks(position: position, values: numericValues) { value in
            chartAxisMarkParts(options, value: value)
        }
    } else if let stringValues = options.stringAxisValues {
        AxisMarks(position: position, values: stringValues) { value in
            chartAxisMarkParts(options, value: value)
        }
    } else {
        AxisMarks(position: position) { value in
            chartAxisMarkParts(options, value: value)
        }
    }
}

@AxisMarkBuilder
private func chartAxisMarkParts(_ options: ChartAxisOption, value: AxisValue) -> some AxisMark {
    if !options.gridHidden {
        AxisGridLine()
    }
    if !options.ticksHidden {
        AxisTick()
    }
    if !options.labelsHidden {
        if let formatter = options.formatter {
            AxisValueLabel {
                Text(formatter.string(for: value))
            }
        } else {
            AxisValueLabel()
        }
    }
}

private struct ChartAxisLabelApplier: ViewModifier {
    let xLabel: String?
    let yLabel: String?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let xLabel, let yLabel {
            content
                .chartXAxisLabel(xLabel)
                .chartYAxisLabel(yLabel)
        } else if let xLabel {
            content.chartXAxisLabel(xLabel)
        } else if let yLabel {
            content.chartYAxisLabel(yLabel)
        } else {
            content
        }
    }
}

private struct ChartScaleApplier: ViewModifier {
    let scales: ChartScaleOptions

    @ViewBuilder
    func body(content: Content) -> some View {
        let xDomain = scales.x?.domain
        let yDomain = scales.y?.domain

        if let xRange = xDomain?.numericRange, let yRange = yDomain?.numericRange {
            content
                .chartXScale(domain: xRange)
                .chartYScale(domain: yRange)
        } else if let xRange = xDomain?.numericRange {
            content.chartXScale(domain: xRange)
        } else if let yRange = yDomain?.numericRange {
            content.chartYScale(domain: yRange)
        } else if let xCategories = xDomain?.stringDomain, let yCategories = yDomain?.stringDomain {
            content
                .chartXScale(domain: xCategories)
                .chartYScale(domain: yCategories)
        } else if let xCategories = xDomain?.stringDomain {
            content.chartXScale(domain: xCategories)
        } else if let yCategories = yDomain?.stringDomain {
            content.chartYScale(domain: yCategories)
        } else {
            content
        }
    }
}

private struct ChartLegendApplier: ViewModifier {
    let legend: ChartLegendOptions

    @ViewBuilder
    func body(content: Content) -> some View {
        if legend.hidden {
            content.chartLegend(.hidden)
        } else {
            content
        }
    }
}

private struct ChartForegroundScaleApplier: ViewModifier {
    let scale: [String: String]

    @ViewBuilder
    func body(content: Content) -> some View {
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

struct ChartSymbolScaleApplier: ViewModifier {
    let scale: [String: ChartMarkStyle.SymbolName]

    @ViewBuilder
    func body(content: Content) -> some View {
        if scale.isEmpty {
            content
        } else {
            let ordered = scale.keys.sorted()
            content.chartSymbolScale(
                domain: ordered,
                range: ordered.map { (scale[$0] ?? .circle).chartsSymbolShape }
            )
        }
    }
}

struct ChartSelectionApplier: ViewModifier {
    @EnvironmentObject private var context: BindJSContext
    let selection: ChartSelectionOptions?

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .modifier(ChartXSelectionApplier(binding: selection?.x, context: context))
            .modifier(ChartYSelectionApplier(binding: selection?.y, context: context))
    }
}

struct ChartXSelectionApplier: ViewModifier {
    let binding: ChartSelectionBinding?
    let context: BindJSContext

    @ViewBuilder
    func body(content: Content) -> some View {
        if let binding {
            switch binding.value {
            case .number(let value):
                content.chartXSelection(value: Binding<Double?>(
                    get: { value },
                    set: { newValue in sendSelection(newValue) }
                ))
            case .string(let value):
                content.chartXSelection(value: Binding<String?>(
                    get: { value },
                    set: { newValue in sendSelection(newValue) }
                ))
            case .bool, .none:
                content.chartXSelection(value: Binding<Double?>(
                    get: { nil },
                    set: { newValue in sendSelection(newValue) }
                ))
            }
        } else {
            content
        }
    }

    private func sendSelection(_ value: Any?) {
        ChartSelectionBridge.dispatch(binding: binding, value: value) { handlerId, selectedValue in
            _ = context.callEventHandler(id: handlerId, arguments: selectedValue)
        }
    }
}

struct ChartYSelectionApplier: ViewModifier {
    let binding: ChartSelectionBinding?
    let context: BindJSContext

    @ViewBuilder
    func body(content: Content) -> some View {
        if let binding {
            switch binding.value {
            case .number(let value):
                content.chartYSelection(value: Binding<Double?>(
                    get: { value },
                    set: { newValue in sendSelection(newValue) }
                ))
            case .string(let value):
                content.chartYSelection(value: Binding<String?>(
                    get: { value },
                    set: { newValue in sendSelection(newValue) }
                ))
            case .bool, .none:
                content.chartYSelection(value: Binding<Double?>(
                    get: { nil },
                    set: { newValue in sendSelection(newValue) }
                ))
            }
        } else {
            content
        }
    }

    private func sendSelection(_ value: Any?) {
        ChartSelectionBridge.dispatch(binding: binding, value: value) { handlerId, selectedValue in
            _ = context.callEventHandler(id: handlerId, arguments: selectedValue)
        }
    }
}

enum ChartSelectionBridge {
    static func dispatch(
        binding: ChartSelectionBinding?,
        value: Any?,
        callback: (String, Any) -> Void
    ) {
        guard let onChangeId = binding?.onChangeId else { return }
        callback(onChangeId, value as Any)
    }
}

private extension ChartAxisOption {
    var hasCustomAxisMarks: Bool {
        values != nil || position != nil || labelsHidden || ticksHidden || gridHidden || formatter != nil
    }

    var axisMarkPosition: AxisMarkPosition? {
        switch position {
        case "top":
            return .top
        case "bottom":
            return .bottom
        case "leading":
            return .leading
        case "trailing":
            return .trailing
        default:
            return nil
        }
    }

    var numericAxisValues: [Double]? {
        switch values {
        case .automatic, .none:
            return nil
        case .values(let values):
            let numbers = values.compactMap { value -> Double? in
                guard case .number(let number) = value else { return nil }
                return number
            }
            return numbers.count == values.count && !numbers.isEmpty ? numbers : nil
        }
    }

    var stringAxisValues: [String]? {
        switch values {
        case .automatic, .none:
            return nil
        case .values(let values):
            let strings = values.compactMap { value -> String? in
                guard case .string(let string) = value else { return nil }
                return string
            }
            return strings.count == values.count && !strings.isEmpty ? strings : nil
        }
    }
}

private extension ChartValueFormatter {
    func string(for value: AxisValue) -> String {
        if let number = value.as(Double.self) {
            return string(for: number)
        }
        if let string = value.as(String.self) {
            return string
        }
        return ""
    }

    private func string(for number: Double) -> String {
        switch self {
        case .number(let minimumFractionDigits, let maximumFractionDigits):
            return numberFormatter(
                style: .decimal,
                minimumFractionDigits: minimumFractionDigits,
                maximumFractionDigits: maximumFractionDigits
            ).string(from: NSNumber(value: number)) ?? "\(number)"
        case .percent(let minimumFractionDigits, let maximumFractionDigits):
            return numberFormatter(
                style: .percent,
                minimumFractionDigits: minimumFractionDigits,
                maximumFractionDigits: maximumFractionDigits
            ).string(from: NSNumber(value: number)) ?? "\(number)"
        case .currency(let currency, let minimumFractionDigits, let maximumFractionDigits):
            let formatter = numberFormatter(
                style: .currency,
                minimumFractionDigits: minimumFractionDigits,
                maximumFractionDigits: maximumFractionDigits
            )
            formatter.currencyCode = currency
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
        case .date:
            return "\(number)"
        }
    }

    private func numberFormatter(
        style: NumberFormatter.Style,
        minimumFractionDigits: Int?,
        maximumFractionDigits: Int?
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        if let minimumFractionDigits {
            formatter.minimumFractionDigits = minimumFractionDigits
        }
        if let maximumFractionDigits {
            formatter.maximumFractionDigits = maximumFractionDigits
        }
        return formatter
    }
}

private extension ChartMarkStyle.SymbolName {
    var chartsSymbolShape: BasicChartSymbolShape {
        switch self {
        case .circle:
            return .circle
        case .square:
            return .square
        case .diamond:
            return .diamond
        case .triangle:
            return .triangle
        case .plus:
            return .plus
        case .cross:
            return .cross
        }
    }
}
