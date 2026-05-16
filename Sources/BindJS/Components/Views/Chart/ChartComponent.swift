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
        .chartXAxis(model.axes.x?.hidden == true ? .hidden : .automatic)
        .chartYAxis(model.axes.y?.hidden == true ? .hidden : .automatic)
        .modifier(ChartAxisLabelApplier(xLabel: model.axes.x?.label, yLabel: model.axes.y?.label))
        .modifier(ChartScaleApplier(scales: model.scales))
        .modifier(ChartLegendApplier(legend: model.legend))
        .modifier(ChartForegroundScaleApplier(scale: model.style.foregroundStyleScale))
        .modifier(ChartSelectionApplier(selection: model.selection))
        .accessibilityLabel(model.accessibility.label ?? "")
        .accessibilityHint(model.accessibility.description ?? "")
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

private struct ChartSelectionApplier: ViewModifier {
    @EnvironmentObject private var context: BindJSContext
    let selection: ChartSelectionOptions?

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .modifier(ChartXSelectionApplier(binding: selection?.x, context: context))
            .modifier(ChartYSelectionApplier(binding: selection?.y, context: context))
    }
}

private struct ChartXSelectionApplier: ViewModifier {
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

private struct ChartYSelectionApplier: ViewModifier {
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
