import AppKit
import BindJS
import SwiftUI

@main
struct BindJSChartPreviewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("BindJS Chart Preview") {
            ChartPreviewRoot()
                .frame(minWidth: 980, minHeight: 660)
        }
        .windowResizability(.contentMinSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        guard let screenshotPath = LaunchOptions.screenshotPath else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchOptions.screenshotDelay) {
            do {
                try captureFrontWindowScreenshot(to: screenshotPath)
            } catch {
                fputs("Screenshot capture failed: \(error)\n", stderr)
                NSApp.terminate(nil)
                return
            }

            if LaunchOptions.quitAfterScreenshot {
                NSApp.terminate(nil)
            }
        }
    }
}

private enum LaunchOptions {
    static let arguments = CommandLine.arguments

    static var fixtureID: String? {
        value(after: "--fixture") ?? value(withPrefix: "--fixture=")
    }

    static var colorScheme: ColorScheme {
        let raw = value(after: "--color-scheme") ?? value(withPrefix: "--color-scheme=")
        return raw == "dark" ? .dark : .light
    }

    static var screenshotPath: String? {
        value(after: "--screenshot") ?? value(withPrefix: "--screenshot=")
    }

    static var screenshotDelay: TimeInterval {
        let raw = value(after: "--screenshot-delay") ?? value(withPrefix: "--screenshot-delay=")
        return raw.flatMap(TimeInterval.init) ?? 3
    }

    static var quitAfterScreenshot: Bool {
        arguments.contains("--quit-after-screenshot")
    }

    private static func value(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func value(withPrefix prefix: String) -> String? {
        arguments.first { $0.hasPrefix(prefix) }.map { String($0.dropFirst(prefix.count)) }
    }
}

private func captureFrontWindowScreenshot(to path: String) throws {
    guard let window = NSApp.windows.first(where: { $0.isVisible && $0.contentView != nil }) else {
        throw ScreenshotError.noVisibleWindow
    }
    guard let contentView = window.contentView else {
        throw ScreenshotError.noContentView
    }

    let bounds = contentView.bounds
    guard let representation = contentView.bitmapImageRepForCachingDisplay(in: bounds) else {
        throw ScreenshotError.noBitmapRepresentation
    }
    contentView.cacheDisplay(in: bounds, to: representation)

    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw ScreenshotError.pngEncodingFailed
    }
    try data.write(to: URL(fileURLWithPath: path))
}

private enum ScreenshotError: Error {
    case noVisibleWindow
    case noContentView
    case noBitmapRepresentation
    case pngEncodingFailed
}

private struct ChartPreviewRoot: View {
    @State private var selection: ChartFixture.ID?
    @State private var colorScheme: ColorScheme

    init() {
        let launchFixture = LaunchOptions.fixtureID.flatMap { id in
            ChartFixture.all.first { $0.id == id }?.id
        }
        _selection = State(initialValue: launchFixture ?? ChartFixture.all.first?.id)
        _colorScheme = State(initialValue: LaunchOptions.colorScheme)
    }

    private var selectedFixture: ChartFixture {
        ChartFixture.all.first { $0.id == selection } ?? ChartFixture.all[0]
    }

    var body: some View {
        NavigationSplitView {
            List(ChartFixture.all, selection: $selection) { fixture in
                Text(fixture.name)
                    .tag(Optional(fixture.id))
            }
            .navigationTitle("Chart Fixtures")
            .frame(minWidth: 240)
        } detail: {
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider()
                chartSurface
                Divider()
                footer
            }
            .preferredColorScheme(colorScheme)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedFixture.name)
                    .font(.title3.weight(.semibold))
                Text(selectedFixture.description)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("Appearance", selection: $colorScheme) {
                Text("Light").tag(ColorScheme.light)
                Text("Dark").tag(ColorScheme.dark)
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
        }
        .padding(18)
    }

    private var chartSurface: some View {
        ScrollView {
            BindJSView(content: selectedFixture.content)
                .id(selectedFixture.id)
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 380, alignment: .center)
        }
        .background(.background)
    }

    private var footer: some View {
        Text("Rendered through BindJSView, JavaScriptCore runtime dispatch, and native Swift Charts.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
    }
}

private struct ChartFixture: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let source: String

    var content: ResolvedContent {
        ResolvedContent(
            compiled: componentSource,
            package: PackageComponents(version: "chart-preview", components: [:])
        )
    }

    private var componentSource: String {
        """
        const metadata = {
          title: "Chart fixture: \(name)",
          description: \(jsonString(description)),
        };
        const body = () => (\(source)).frame({ height: 320 });
        const previews = [Self().previewName("Default")];
        exports.default = defineComponent({ metadata, body, previews });
        """
    }

    static let all: [ChartFixture] = [
        ChartFixture(
            name: "net-worth-card",
            description: "Vault net_worth_trend chart: hidden axes, explicit domains, area + rule + monotone line.",
            source: #"Chart({}, [ForEach([{l:'Jun',v:34200},{l:'Jul',v:35100},{l:'Aug',v:35800},{l:'Sep',v:35200},{l:'Oct',v:36400},{l:'Nov',v:37500},{l:'Dec',v:36900},{l:'Jan',v:38800},{l:'Feb',v:40100},{l:'Mar',v:41200},{l:'Apr',v:42300},{l:'May',v:43470}], (p, i) => AreaMark({ x: i, y: p.v }).foregroundStyle(Color('#34C759').opacity(0.18)).interpolationMethod('monotone')), RuleMark({ y: 34200 }).foregroundStyle(Color('secondary').opacity(0.4)).lineStyle({ width: 1, dash: [4, 3] }), ForEach([{l:'Jun',v:34200},{l:'Jul',v:35100},{l:'Aug',v:35800},{l:'Sep',v:35200},{l:'Oct',v:36400},{l:'Nov',v:37500},{l:'Dec',v:36900},{l:'Jan',v:38800},{l:'Feb',v:40100},{l:'Mar',v:41200},{l:'Apr',v:42300},{l:'May',v:43470}], (p, i) => LineMark({ x: i, y: p.v }).foregroundStyle(Color('#34C759')).interpolationMethod('monotone').lineStyle({ width: 2.5 }))]).chartXAxis({ hidden: true, gridHidden: true }).chartYAxis({ hidden: true, gridHidden: true }).chartXScale({ type: 'linear', domain: [0, 11] }).chartYScale({ domain: [33087.6, 44582.4] }).allowsHitTesting(false).padding('trailing', 14)"#
        ),
        ChartFixture(
            name: "bar-single-series",
            description: "Single-series bar chart with visible axes.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }], row => BarMark({ x: { value: row.month, label: 'Month' }, y: { value: row.value, label: 'Revenue' } }))]).chartXAxisLabel('Month').chartYAxisLabel('Revenue')"#
        ),
        ChartFixture(
            name: "bar-multi-series",
            description: "Grouped bar data colored by series.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', region: 'North', value: 12 }, { month: 'Jan', region: 'South', value: 9 }, { month: 'Feb', region: 'North', value: 18 }, { month: 'Feb', region: 'South', value: 15 }], row => BarMark({ x: { value: row.month, label: 'Month' }, y: { value: row.value, label: 'Revenue' } }).foregroundStyle({ by: { value: row.region, label: 'Region' } }))]).chartForegroundStyleScale({ North: 'blue', South: 'green' })"#
        ),
        ChartFixture(
            name: "bar-stacked",
            description: "Stacked bar data colored by series.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', region: 'North', value: 12 }, { month: 'Jan', region: 'South', value: 9 }, { month: 'Feb', region: 'North', value: 18 }, { month: 'Feb', region: 'South', value: 15 }], row => BarMark({ x: { value: row.month }, y: { value: row.value }, stacking: 'standard' }).foregroundStyle({ by: row.region }))])"#
        ),
        ChartFixture(
            name: "line-single",
            description: "Single-series line chart over date values.",
            source: #"Chart({}, [ForEach([{ date: '2026-01-01', value: 12 }, { date: '2026-02-01', value: 15 }, { date: '2026-03-01', value: 21 }], row => LineMark({ x: { value: row.date, label: 'Date' }, y: { value: row.value, label: 'Value' } }))]).chartXScale({ type: 'date' })"#
        ),
        ChartFixture(
            name: "line-multi-series",
            description: "Multi-series line chart using foregroundStyle({ by }).",
            source: #"Chart({}, [ForEach([{ date: '2026-01-01', region: 'North', value: 12 }, { date: '2026-02-01', region: 'North', value: 15 }, { date: '2026-01-01', region: 'South', value: 8 }, { date: '2026-02-01', region: 'South', value: 13 }], row => LineMark({ x: { value: row.date }, y: { value: row.value } }).foregroundStyle({ by: row.region }))]).chartXScale({ type: 'date' })"#
        ),
        ChartFixture(
            name: "line-with-points",
            description: "Layered LineMark and PointMark.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }, { month: 'Mar', value: 14 }], row => Group([LineMark({ x: { value: row.month }, y: { value: row.value } }), PointMark({ x: { value: row.month }, y: { value: row.value } })]))])"#
        ),
        ChartFixture(
            name: "area-stacked",
            description: "Stacked AreaMark series.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', region: 'North', value: 12 }, { month: 'Jan', region: 'South', value: 9 }, { month: 'Feb', region: 'North', value: 18 }, { month: 'Feb', region: 'South', value: 15 }], row => AreaMark({ x: { value: row.month }, y: { value: row.value }, stacking: 'standard' }).foregroundStyle({ by: row.region }))])"#
        ),
        ChartFixture(
            name: "line-with-rule",
            description: "Line chart with a y-value reference rule.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }, { month: 'Mar', value: 14 }], row => LineMark({ x: { value: row.month }, y: { value: row.value } })), RuleMark({ y: { value: 15, label: 'Average' } }).foregroundStyle(Color('red')).lineStyle({ dash: [4, 2] })])"#
        ),
        ChartFixture(
            name: "hidden-axis",
            description: "Line chart with hidden x-axis.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }], row => LineMark({ x: { value: row.month }, y: { value: row.value } }))]).chartXAxis({ hidden: true })"#
        ),
        ChartFixture(
            name: "custom-domain",
            description: "Bar chart with an explicit y-domain.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 42 }, { month: 'Feb', value: 64 }], row => BarMark({ x: { value: row.month }, y: { value: row.value } }))]).chartYScale({ domain: [0, 100] })"#
        ),
        ChartFixture(
            name: "legend-hidden",
            description: "Multi-series chart with legend hidden.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', region: 'North', value: 12 }, { month: 'Jan', region: 'South', value: 9 }], row => BarMark({ x: { value: row.month }, y: { value: row.value } }).foregroundStyle({ by: row.region }))]).chartLegend({ hidden: true })"#
        ),
        ChartFixture(
            name: "interpolation-monotone",
            description: "Line chart using monotone interpolation.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }, { month: 'Mar', value: 14 }], row => LineMark({ x: { value: row.month }, y: { value: row.value } }).interpolationMethod('monotone'))])"#
        ),
        ChartFixture(
            name: "accessibility-labeled",
            description: "Chart and mark accessibility labels.",
            source: #"Chart({}, [BarMark({ x: { value: 'Jan' }, y: { value: 12 } }).accessibilityLabel('January revenue')]).accessibilityLabel('Revenue by month').accessibilityHint('Bar chart of monthly revenue')"#
        ),
        ChartFixture(
            name: "x-rule-reference",
            description: "Tier 2A x-value reference rule.",
            source: #"Chart({}, [BarMark({ x: { value: 'Jan' }, y: { value: 12 } }), BarMark({ x: { value: 'Feb' }, y: { value: 18 } }), RuleMark({ x: { value: 'Feb', label: 'Release' } }).foregroundStyle(Color('red')).lineStyle({ dash: [4, 2] })])"#
        ),
        ChartFixture(
            name: "heatmap-cells",
            description: "Tier 2A RectangleMark heatmap cells.",
            source: #"Chart({}, [RectangleMark({ x: { value: 'Jan', label: 'Month' }, y: { value: 'North', label: 'Region' } }).foregroundStyle({ by: { value: 'High', label: 'Intensity' } }), RectangleMark({ x: { value: 'Feb', label: 'Month' }, y: { value: 'South', label: 'Region' } }).foregroundStyle({ by: { value: 'Low', label: 'Intensity' } })]).chartForegroundStyleScale({ High: 'red', Low: 'blue' })"#
        ),
        ChartFixture(
            name: "rectangle-ranges",
            description: "Tier 2A RectangleMark range rectangles with optional secondary channels.",
            source: #"Chart({}, [RectangleMark({ x: { value: 'Jan', label: 'Start' }, x2: { value: 'Feb', label: 'End' }, y: { value: 'North', label: 'Start region' }, y2: { value: 'South', label: 'End region' } }).foregroundStyle(Color('blue')), RectangleMark({ x: { value: 'Feb', label: 'Start' }, x2: { value: 'Mar', label: 'End' }, y: { value: 'South', label: 'Start region' }, y2: { value: 'West', label: 'End region' } }).foregroundStyle(Color('green'))])"#
        ),
        ChartFixture(
            name: "axis-explicit-values",
            description: "Tier 2A explicit axis values and top axis position.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', value: 12 }, { month: 'Feb', value: 18 }, { month: 'Mar', value: 14 }], row => LineMark({ x: { value: row.month, label: 'Month' }, y: { value: row.value, label: 'Revenue' } }))]).chartXAxis({ values: ['Jan', 'Feb', 'Mar'], position: 'top' })"#
        ),
        ChartFixture(
            name: "axis-formatter-currency",
            description: "Tier 2A declarative currency formatter metadata.",
            source: #"Chart({}, [BarMark({ x: { value: 'Jan' }, y: { value: 1200 } }), BarMark({ x: { value: 'Feb' }, y: { value: 1800 } })]).chartYAxis({ formatter: { style: 'currency', currency: 'USD', maximumFractionDigits: 0 } })"#
        ),
        ChartFixture(
            name: "axis-grid-tick-hidden",
            description: "Tier 2A declarative axis label, tick, and grid visibility.",
            source: #"Chart({}, [LineMark({ x: { value: 'Jan' }, y: { value: 12 } }), LineMark({ x: { value: 'Feb' }, y: { value: 18 } })]).chartXAxis({ ticksHidden: true, gridHidden: true }).chartYAxis({ labelsHidden: true })"#
        ),
        ChartFixture(
            name: "point-symbols",
            description: "Tier 2A point symbols, symbol size, annotation, and symbol scale.",
            source: #"Chart({}, [PointMark({ x: { value: 'Jan', label: 'Month' }, y: { value: 12, label: 'Revenue' } }).foregroundStyle({ by: { value: 'North', label: 'Region' } }).symbol('diamond').symbolSize(96).annotation({ text: 'Peak', position: 'top' })]).chartSymbolScale({ North: 'diamond' })"#
        ),
        ChartFixture(
            name: "symbol-scale-series",
            description: "Tier 2A finite portable symbol scale across all supported symbols.",
            source: #"Chart({}, [ForEach([{ month: 'Jan', region: 'circle', value: 10 }, { month: 'Feb', region: 'square', value: 12 }, { month: 'Mar', region: 'diamond', value: 14 }, { month: 'Apr', region: 'triangle', value: 16 }, { month: 'May', region: 'plus', value: 18 }, { month: 'Jun', region: 'cross', value: 20 }], row => PointMark({ x: { value: row.month }, y: { value: row.value } }).foregroundStyle({ by: { value: row.region, label: 'Symbol' } }))]).chartSymbolScale({ circle: 'circle', square: 'square', diamond: 'diamond', triangle: 'triangle', plus: 'plus', cross: 'cross' })"#
        ),
        ChartFixture(
            name: "mark-text-annotation",
            description: "Tier 2A text-only mark annotation.",
            source: #"Chart({}, [LineMark({ x: { value: 'Jan' }, y: { value: 12 } }), PointMark({ x: { value: 'Feb' }, y: { value: 18 } }).annotation({ text: 'Peak', position: 'top' })])"#
        ),
        ChartFixture(
            name: "x-selection-controlled",
            description: "Tier 2A controlled x-axis selection bridge metadata.",
            source: #"Chart({}, [PointMark({ x: { value: 'Jan', label: 'Month' }, y: { value: 12, label: 'Revenue' } }), PointMark({ x: { value: 'Feb', label: 'Month' }, y: { value: 18, label: 'Revenue' } })]).chartXSelection({ value: 'Jan', onChange: value => value })"#
        ),
        ChartFixture(
            name: "pie-basic",
            description: "Tier 2B basic pie chart with literal slice values.",
            source: #"PieChart({}, [PieSliceMark({ id: 'product', value: 45, label: 'Product' }), PieSliceMark({ id: 'services', value: 35, label: 'Services' }), PieSliceMark({ id: 'support', value: 20, label: 'Support' })])"#
        ),
        ChartFixture(
            name: "pie-color-scale",
            description: "Tier 2B pie chart using foregroundStyle series keys and a color scale.",
            source: #"PieChart({}, [PieSliceMark({ id: 'product', value: 45, label: 'Product' }).foregroundStyle({ by: 'Product' }), PieSliceMark({ id: 'services', value: 35, label: 'Services' }).foregroundStyle({ by: 'Services' }), PieSliceMark({ id: 'support', value: 20, label: 'Support' }).foregroundStyle({ by: 'Support' })]).chartForegroundStyleScale({ Product: 'blue', Services: 'green', Support: 'orange' })"#
        ),
        ChartFixture(
            name: "donut-basic",
            description: "Tier 2B donut chart using normalized innerRadius.",
            source: #"PieChart({ innerRadius: 0.55 }, [PieSliceMark({ id: 'north', value: 40, label: 'North' }), PieSliceMark({ id: 'south', value: 25, label: 'South' }), PieSliceMark({ id: 'west', value: 35, label: 'West' })])"#
        ),
        ChartFixture(
            name: "pie-legend-hidden",
            description: "Tier 2B pie chart with legend hidden.",
            source: #"PieChart({}, [PieSliceMark({ id: 'north', value: 40, label: 'North' }).foregroundStyle({ by: 'North' }), PieSliceMark({ id: 'south', value: 60, label: 'South' }).foregroundStyle({ by: 'South' })]).chartForegroundStyleScale({ North: 'blue', South: 'green' }).chartLegend({ hidden: true })"#
        ),
        ChartFixture(
            name: "pie-accessibility-labeled",
            description: "Tier 2B pie chart and slice accessibility metadata.",
            source: #"PieChart({}, [PieSliceMark({ id: 'product', value: 45, label: 'Product' }).accessibilityLabel('Product revenue share').accessibilityValue('45 percent'), PieSliceMark({ id: 'services', value: 35, label: 'Services' }).accessibilityLabel('Services revenue share').accessibilityValue('35 percent')]).accessibilityLabel('Revenue share').accessibilityHint('Pie chart of revenue by business line')"#
        ),
        ChartFixture(
            name: "pie-selection-controlled",
            description: "Tier 2B controlled single-slice pie selection bridge metadata.",
            source: #"PieChart({}, [PieSliceMark({ id: 'product', value: 45, label: 'Product' }), PieSliceMark({ id: 'services', value: 35, label: 'Services' }), PieSliceMark({ id: 'support', value: 20, label: 'Support' })]).chartSelection({ value: 'product', onChange: value => value })"#
        )
    ]

    init(name: String, description: String, source: String) {
        self.id = name
        self.name = name
        self.description = description
        self.source = source
    }
}

private func jsonString(_ value: String) -> String {
    let data = try? JSONEncoder().encode(value)
    return data.flatMap { String(data: $0, encoding: .utf8) } ?? #""""#
}
