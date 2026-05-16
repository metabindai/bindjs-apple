import Charts
import Foundation
import SwiftUI

public struct PieChartComponent: Component {
    public static var directiveName: String = "PieChart"

    public var children: [Component]
    public var innerRadius: Double?
}

extension PieChartComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        children = directive.children.compactMap { makeComponent($0) }
        innerRadius = Self.number(from: directive.props["innerRadius"])
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitPieChart(self)
    }

    private static func number(from raw: Any?) -> Double? {
        switch raw {
        case let value as Int:
            return Double(value)
        case let value as Double:
            return value
        case let value as Float:
            return Double(value)
        case let value as NSNumber:
            if CFGetTypeID(value) == CFBooleanGetTypeID() {
                return nil
            }
            return value.doubleValue
        default:
            return nil
        }
    }
}

extension PieChartComponent: View {
    public var body: some View {
        PieChartRenderedView(model: PieChartCollector.collect(chart: self))
    }
}

struct PieChartRenderedView: View {
    let model: PieChartModel

    var body: some View {
        Chart {
            PieSliceContent(model: model)
        }
        .modifier(PieChartLegendApplier(legend: model.legend))
        .modifier(PieChartForegroundScaleApplier(scale: model.style.foregroundStyleScale))
        .modifier(PieChartSelectionApplier(model: model))
        .accessibilityLabel(model.accessibility.label ?? "")
        .accessibilityHint(model.accessibility.description ?? "")
    }
}

private struct PieSliceContent: ChartContent {
    let model: PieChartModel

    var body: some ChartContent {
        ForEach(model.slices.filter { $0.value > 0 }) { slice in
            styledSector(
                SectorMark(
                    angle: .value(slice.label ?? "Value", slice.value),
                    innerRadius: .ratio(model.normalizedInnerRadius)
                ),
                slice: slice
            )
        }
    }
}

@ChartContentBuilder
private func styledSector<Content: ChartContent>(_ content: Content, slice: PieSliceMark) -> some ChartContent {
    let rounded = slice.style.cornerRadius.map { content.cornerRadius($0) }
    if let rounded {
        foregroundStyled(rounded, slice: slice)
    } else {
        foregroundStyled(content, slice: slice)
    }
}

@ChartContentBuilder
private func foregroundStyled<Content: ChartContent>(_ content: Content, slice: PieSliceMark) -> some ChartContent {
    switch slice.style.foregroundStyle {
    case .color(let color):
        accessibilityStyled(content.foregroundStyle(Color.chartColor(named: color)), slice: slice)
    case .series(let channel):
        accessibilityStyled(content.foregroundStyle(by: .value(channel.label ?? "Series", channel.accessibilityKey)), slice: slice)
    case .none:
        accessibilityStyled(content.foregroundStyle(by: .value("Slice", slice.label ?? slice.id)), slice: slice)
    }
}

@ChartContentBuilder
private func accessibilityStyled<Content: ChartContent>(_ content: Content, slice: PieSliceMark) -> some ChartContent {
    if let label = slice.accessibility.label, let value = slice.accessibility.value {
        content
            .accessibilityLabel(label)
            .accessibilityValue(value)
    } else if let label = slice.accessibility.label {
        content.accessibilityLabel(label)
    } else if let value = slice.accessibility.value {
        content.accessibilityValue(value)
    } else {
        content
    }
}

private struct PieChartLegendApplier: ViewModifier {
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

private struct PieChartForegroundScaleApplier: ViewModifier {
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

private struct PieChartSelectionApplier: ViewModifier {
    @EnvironmentObject private var context: BindJSContext
    let model: PieChartModel

    @ViewBuilder
    func body(content: Content) -> some View {
        if model.selection?.onChangeId != nil {
            content.chartAngleSelection(value: Binding<Double?>(
                get: { PieSelectionBridge.angleValue(for: model.selection?.value, in: model) },
                set: { newValue in sendSelection(newValue) }
            ))
        } else {
            content
        }
    }

    private func sendSelection(_ value: Double?) {
        PieSelectionBridge.dispatch(selection: model.selection, angleValue: value, model: model) { handlerId, selectedValue in
            _ = context.callEventHandler(id: handlerId, arguments: selectedValue)
        }
    }
}

enum PieSelectionBridge {
    static func angleValue(for selectedId: String?, in model: PieChartModel) -> Double? {
        guard let selectedId else { return nil }
        var cursor = 0.0
        for slice in model.slices where slice.value > 0 {
            let start = cursor
            cursor += slice.value
            if slice.id == selectedId {
                return start + (slice.value / 2)
            }
        }
        return nil
    }

    static func sliceId(for angleValue: Double?, in model: PieChartModel) -> String? {
        guard let angleValue else { return nil }
        var cursor = 0.0
        for slice in model.slices where slice.value > 0 {
            cursor += slice.value
            if angleValue <= cursor {
                return slice.id
            }
        }
        return model.slices.last(where: { $0.value > 0 })?.id
    }

    static func dispatch(
        selection: PieSelectionBinding?,
        angleValue: Double?,
        model: PieChartModel,
        callback: (String, Any) -> Void
    ) {
        guard let onChangeId = selection?.onChangeId else { return }
        callback(onChangeId, sliceId(for: angleValue, in: model) as Any)
    }
}

private extension PieChartModel {
    var normalizedInnerRadius: CGFloat {
        CGFloat(max(0, min(innerRadius ?? 0, 1)))
    }
}

private extension ChartChannel {
    var accessibilityKey: String {
        value.accessibilityText
    }
}
