import SwiftUI
import Testing
@testable import BindJS

@Suite("BindJS Charts")
struct ChartContentDispatchTests {
    @Test func swiftChartsDispatcherAcceptsRuntimeMarks() {
        let model = ChartModel(marks: [
            ChartMark(
                id: "bar",
                kind: .bar,
                channels: ChartMarkChannels(
                    x: ChartChannel(value: .string("Jan"), label: "Month"),
                    y: ChartChannel(value: .number(12), label: "Revenue")
                ),
                style: ChartMarkStyle(foregroundStyle: .color("red"), stacking: .unstacked)
            ),
            ChartMark(
                id: "line",
                kind: .line,
                channels: ChartMarkChannels(
                    x: ChartChannel(value: .string("Jan"), label: "Month"),
                    y: ChartChannel(value: .number(10), label: "Revenue")
                ),
                style: ChartMarkStyle(
                    foregroundStyle: .series(ChartChannel(value: .string("North"), label: "Region")),
                    lineStyle: ChartLineStyle(width: 3, dash: [4, 2]),
                    interpolationMethod: .monotone
                )
            ),
            ChartMark(
                id: "area",
                kind: .area,
                channels: ChartMarkChannels(
                    x: ChartChannel(value: .string("Jan"), label: "Month"),
                    y: ChartChannel(value: .number(8), label: "Revenue")
                ),
                style: ChartMarkStyle(interpolationMethod: .linear, stacking: .standard)
            ),
            ChartMark(
                id: "point",
                kind: .point,
                channels: ChartMarkChannels(
                    x: ChartChannel(value: .string("Jan"), label: "Month"),
                    y: ChartChannel(value: .number(12), label: "Revenue")
                )
            ),
            ChartMark(
                id: "rule",
                kind: .rule,
                channels: ChartMarkChannels(y: ChartChannel(value: .number(10), label: "Target"))
            ),
            ChartMark(
                id: "rectangle",
                kind: .rectangle,
                channels: ChartMarkChannels(
                    x: ChartChannel(value: .string("Jan"), label: "Month"),
                    y: ChartChannel(value: .string("North"), label: "Region"),
                    y2: ChartChannel(value: .string("South"), label: "Region")
                )
            )
        ])

        _ = ChartRenderedView(model: model)
        #expect(model.marks.map(\.kind) == [.bar, .line, .area, .point, .rule, .rectangle])
    }

    @Test func swiftChartsDispatcherAcceptsPieSlices() {
        let model = PieChartModel(
            slices: [
                PieSliceMark(id: "north", value: 40, label: "North", style: PieSliceStyle(foregroundStyle: .color("blue"))),
                PieSliceMark(id: "south", value: 25, label: "South", style: PieSliceStyle(foregroundStyle: .series(ChartChannel(value: .string("South"), label: "Region"))))
            ],
            innerRadius: 0.45
        )

        _ = PieChartRenderedView(model: model)
        #expect(model.slices.map(\.id) == ["north", "south"])
    }
}

@Suite("ChartCollector")
struct ChartCollectorTests {
    @Test func collectsDirectMarksAndStyles() throws {
        let chart = try chart([
            bar(x: "Jan", y: 12)
                .modifier(Directive(type: "foregroundStyle", props: ["rawValue": "red"]))
                .modifier(Directive(type: "cornerRadius", props: ["rawValue": 6]))
                .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "January revenue"]))
        ])

        let model = ChartCollector.collect(chart: chart)

        #expect(model.marks.count == 1)
        #expect(model.marks[0].kind == .bar)
        #expect(model.marks[0].style.foregroundStyle == .color("red"))
        #expect(model.marks[0].style.cornerRadius == 6)
        #expect(model.marks[0].accessibility.label == "January revenue")
        #expect(model.diagnostics.isEmpty)
    }

    @Test func flattensForEachAndGroupChildren() throws {
        var forEach = ForEachComponent(from: Directive(type: "ForEach", props: ["count": 2]))!
        forEach.resolvedChildren = [
            try component(bar(x: "Jan", y: 12)),
            try component(line(x: "Feb", y: 15))
        ]

        let group = GroupComponent(content: [
            try component(area(x: "Mar", y: 18)),
            forEach
        ])

        let model = ChartCollector.collect(chart: ChartComponent(children: [group]))

        #expect(model.marks.map(\.kind) == [.area, .bar, .line])
        #expect(model.diagnostics.isEmpty)
    }

    @Test func foldsMarkModifiers() throws {
        let chart = try chart([
            line(x: "Jan", y: 12)
                .modifier(Directive(type: "foregroundStyle", props: ["by": "North", "label": "Region"]))
                .modifier(Directive(type: "lineStyle", props: ["width": 4, "dash": [5, 2]]))
                .modifier(Directive(type: "interpolationMethod", props: ["rawValue": "monotone"]))
        ])

        let mark = ChartCollector.collect(chart: chart).marks[0]

        #expect(mark.style.foregroundStyle == .series(ChartChannel(value: .string("North"), label: "Region")))
        #expect(mark.style.lineStyle == ChartLineStyle(width: 4, dash: [5, 2]))
        #expect(mark.style.interpolationMethod == .monotone)
    }

    @Test func collectsStackingFromMarkProps() throws {
        let chart = try chart([
            Directive(type: "BarMark", props: [
                "x": ["value": "Jan"],
                "y": ["value": 12],
                "stacking": "unstacked"
            ])
        ])

        #expect(ChartCollector.collect(chart: chart).marks[0].style.stacking == .unstacked)
    }

    @Test func rejectsNonMarkChildren() throws {
        let chart = try chart([
            Directive(type: "Text", props: ["rawValue": "Nope"])
        ])

        let diagnostics = ChartCollector.collect(chart: chart).diagnostics

        #expect(diagnostics.contains { $0.severity == .error && $0.message.contains("Chart children must be chart marks") })
    }

    @Test func rejectsChartLevelModifierOnMark() throws {
        let chart = try chart([
            bar(x: "Jan", y: 12)
                .modifier(Directive(type: "chartYAxis", props: ["hidden": true]))
        ])

        let diagnostics = ChartCollector.collect(chart: chart).diagnostics

        #expect(diagnostics.contains { $0.severity == .error && $0.message.contains("cannot be attached") })
    }

    @Test func rejectsInvalidScaleDomain() throws {
        let root = try component(
            Directive(type: "Chart", children: [bar(x: "Jan", y: 12)])
                .modifier(Directive(type: "chartYScale", props: ["domain": [20, 0]]))
        )

        let diagnostics = try #require(ChartCollector.collect(root: root)?.diagnostics)

        #expect(diagnostics.contains { $0.severity == .error && $0.message.contains("Invalid chart y-scale domain") })
    }

    @Test func collectsTierOneFixtureSet() throws {
        let fixtures = try chartFixtureRoots()

        #expect(fixtures.map(\.name) == allChartFixtureNames)
        for fixture in fixtures {
            if chartFixtureNames.contains(fixture.name) {
                let model = try #require(ChartCollector.collect(root: fixture.root), "Missing chart model for \(fixture.name)")
                #expect(!model.marks.isEmpty, "\(fixture.name) should produce at least one mark")
                #expect(!model.diagnostics.contains { $0.severity == .error }, "\(fixture.name) should not produce chart errors")
            } else {
                let model = try #require(PieChartCollector.collect(root: fixture.root), "Missing pie chart model for \(fixture.name)")
                #expect(!model.slices.isEmpty, "\(fixture.name) should produce at least one slice")
                #expect(!model.diagnostics.contains { $0.severity == .error }, "\(fixture.name) should not produce pie chart errors")
            }
        }
    }

    @Test func sharedFixtureNamesMatchAppleFixturesWhenAvailable() throws {
        let packageRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let sharedFixturesURL = packageRoot
            .deletingLastPathComponent()
            .appendingPathComponent("metabind-server/scripts/fixtures/charts/charts-fixtures.json")

        guard FileManager.default.fileExists(atPath: sharedFixturesURL.path) else {
            return
        }

        let data = try Data(contentsOf: sharedFixturesURL)
        let raw = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        let names = raw.compactMap { $0["name"] as? String }

        #expect(names == allChartFixtureNames)
    }

    @Test func foldsChartLevelModifiersFromModifiedRoot() throws {
        let root = try component(
            Directive(type: "Chart", children: [bar(x: "Jan", y: 12)])
                .modifier(Directive(type: "chartYAxis", props: ["hidden": true]))
                .modifier(Directive(type: "chartYScale", props: ["domain": [0, 20]]))
                .modifier(Directive(type: "chartLegend", props: ["visibility": "hidden"]))
                .modifier(Directive(type: "chartYAxisLabel", props: ["rawValue": "Revenue"]))
                .modifier(Directive(type: "accessibilityHint", props: ["rawValue": "Monthly revenue chart"]))
        )

        let model = try #require(ChartCollector.collect(root: root))

        #expect(model.axes.y?.hidden == true)
        #expect(model.axes.y?.label == "Revenue")
        #expect(model.scales.y?.domain == [.number(0), .number(20)])
        #expect(model.legend.hidden == true)
        #expect(model.accessibility.description == "Monthly revenue chart")
    }

    @Test @MainActor func runtimeConstructorsEmitChartDirectives() throws {
        let context = BindJSContext()
        context.register(
            name: "ChartSmoke",
            source: """
            const body = () => Chart({}, [
              BarMark({ x: { value: "Jan" }, y: { value: 12 } }).foregroundStyle("red"),
              LineMark({ x: { value: "Feb" }, y: { value: 14 } }).interpolationMethod("monotone")
            ]).chartYAxis({ hidden: true });
            """
        )

        let component = try #require(context.componentForName("ChartSmoke"))
        let model = try #require(ChartCollector.collect(root: component))

        #expect(model.marks.map(\.kind) == [.bar, .line])
        #expect(model.axes.y?.hidden == true)
        #expect(model.marks[0].style.foregroundStyle == .color("red"))
        #expect(model.marks[1].style.interpolationMethod == .monotone)
    }

    @Test func collectsTierTwoCartesianModifiers() throws {
        let root = try component(
            Directive(type: "Chart", children: [
                rectangle(x: "Jan", y: "North", y2: "South"),
                point(x: "Jan", y: 12)
                    .modifier(Directive(type: "symbol", props: ["rawValue": "diamond"]))
                    .modifier(Directive(type: "symbolSize", props: ["rawValue": 96]))
                    .modifier(Directive(type: "annotation", props: ["text": "Peak", "position": "top"])),
                Directive(type: "RuleMark", props: ["x": ["value": "Feb", "label": "Month"]])
                    .modifier(Directive(type: "annotation", props: ["rawValue": "Launch", "position": "trailing"]))
            ])
            .modifier(Directive(type: "chartXAxis", props: [
                "values": ["Jan", "Feb", true],
                "position": "top",
                "labelsHidden": true,
                "formatter": ["style": "number", "maximumFractionDigits": 0]
            ]))
            .modifier(Directive(type: "chartSymbolScale", props: ["North": "circle", "South": "square"]))
            .modifier(Directive(type: "chartXSelection", props: ["value": "Jan", "onChangeId": "selectMonth"]))
            .modifier(Directive(type: "chartYSelection", props: ["value": 12, "onChangeId": "selectValue"]))
        )

        let model = try #require(ChartCollector.collect(root: root))

        #expect(model.marks.map(\.kind) == [.rectangle, .point, .rule])
        #expect(model.marks[0].channels.x?.value == .string("Jan"))
        #expect(model.marks[0].channels.y?.value == .string("North"))
        #expect(model.marks[0].channels.y2?.value == .string("South"))
        #expect(model.marks[1].style.symbol == .diamond)
        #expect(model.marks[1].style.symbolSize == 96)
        #expect(model.marks[1].style.annotation == ChartAnnotation(text: "Peak", position: .top))
        #expect(model.marks[2].channels.x?.value == .string("Feb"))
        #expect(model.marks[2].style.annotation == ChartAnnotation(text: "Launch", position: .trailing))
        #expect(model.axes.x?.values == .values([.string("Jan"), .string("Feb")]))
        #expect(model.axes.x?.position == "top")
        #expect(model.axes.x?.labelsHidden == true)
        #expect(model.axes.x?.formatter == .number(minimumFractionDigits: nil, maximumFractionDigits: 0))
        #expect(model.style.symbolScale == ["North": .circle, "South": .square])
        #expect(model.selection?.x == ChartSelectionBinding(value: .string("Jan"), onChangeId: "selectMonth"))
        #expect(model.selection?.y == ChartSelectionBinding(value: .number(12), onChangeId: "selectValue"))
        #expect(model.diagnostics.isEmpty)
    }

    @Test func chartSelectionBridgeDispatchesPortablePayload() {
        var events: [(String, ChartValue)] = []

        ChartSelectionBridge.dispatch(
            binding: ChartSelectionBinding(value: .string("Jan"), onChangeId: "selectMonth"),
            value: "Feb"
        ) { handlerId, selectedValue in
            if let value = ChartValue(selectedValue) {
                events.append((handlerId, value))
            }
        }

        #expect(events.count == 1)
        #expect(events[0].0 == "selectMonth")
        #expect(events[0].1 == .string("Feb"))
    }

    @Test func collectsPieSlicesAndModifiers() throws {
        let root = try component(
            Directive(type: "PieChart", props: ["innerRadius": 1.6], children: [
                pieSlice(id: "north", value: 40, label: "North")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "North", "label": "Region"]))
                    .modifier(Directive(type: "cornerRadius", props: ["rawValue": 3]))
                    .modifier(Directive(type: "accessibilityValue", props: ["rawValue": "40 percent"])),
                pieSlice(value: 25, label: "South")
            ])
            .modifier(Directive(type: "chartForegroundStyleScale", props: ["North": "blue", "South": "green"]))
            .modifier(Directive(type: "chartLegend", props: ["visibility": "hidden"]))
            .modifier(Directive(type: "chartSelection", props: ["value": "north", "onChangeId": "selectRegion"]))
            .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "Revenue share"]))
        )

        let model = try #require(PieChartCollector.collect(root: root))

        #expect(model.innerRadius == 1)
        #expect(model.slices.count == 2)
        #expect(model.slices[0].id == "north")
        #expect(model.slices[0].value == 40)
        #expect(model.slices[0].label == "North")
        #expect(model.slices[0].style.foregroundStyle == .series(ChartChannel(value: .string("North"), label: "Region")))
        #expect(model.slices[0].style.cornerRadius == 3)
        #expect(model.slices[0].accessibility.value == "40 percent")
        #expect(model.slices[1].id == "PieChart.children[1]")
        #expect(model.style.foregroundStyleScale == ["North": "blue", "South": "green"])
        #expect(model.legend.hidden == true)
        #expect(model.selection == PieSelectionBinding(value: "north", onChangeId: "selectRegion"))
        #expect(model.accessibility.label == "Revenue share")
        #expect(model.diagnostics.isEmpty)
    }

    @Test func rejectsInvalidPieChildrenAndModifiers() throws {
        let root = try component(
            Directive(type: "PieChart", children: [
                bar(x: "Jan", y: 12),
                pieSlice(value: 10).modifier(Directive(type: "lineStyle", props: ["width": 2]))
            ])
            .modifier(Directive(type: "chartXSelection", props: ["value": "Jan", "onChangeId": "selectMonth"]))
        )

        let model = try #require(PieChartCollector.collect(root: root))

        #expect(model.diagnostics.contains { $0.severity == .error && $0.message.contains("Cartesian mark") })
        #expect(model.diagnostics.contains { $0.severity == .error && $0.message.contains("Cartesian-only mark modifier") })
        #expect(model.diagnostics.contains { $0.severity == .error && $0.message.contains("use chartSelection") })
    }

    @Test func pieSelectionBridgeDispatchesSliceId() {
        let model = PieChartModel(slices: [
            PieSliceMark(id: "north", value: 40, label: "North"),
            PieSliceMark(id: "south", value: 60, label: "South")
        ])
        var events: [(String, String?)] = []

        PieSelectionBridge.dispatch(
            selection: PieSelectionBinding(value: "north", onChangeId: "selectRegion"),
            angleValue: 41,
            model: model
        ) { handlerId, selectedValue in
            events.append((handlerId, selectedValue as? String))
        }

        #expect(PieSelectionBridge.angleValue(for: "north", in: model) == 20)
        #expect(events.count == 1)
        #expect(events[0].0 == "selectRegion")
        #expect(events[0].1 == "south")
    }

    @Test @MainActor func runtimeConstructorsEmitPieDirectives() throws {
        let context = BindJSContext()
        context.register(
            name: "PieSmoke",
            source: """
            const body = () => PieChart({ innerRadius: 0.5 }, [
              PieSliceMark({ id: "north", value: 40, label: "North" }).foregroundStyle({ by: "North", label: "Region" }),
              PieSliceMark({ id: "south", value: 60, label: "South" })
            ]).chartSelection({ value: "north", onChangeId: "selectRegion" });
            """
        )

        let component = try #require(context.componentForName("PieSmoke"))
        let model = try #require(PieChartCollector.collect(root: component))

        #expect(model.innerRadius == 0.5)
        #expect(model.slices.map(\.id) == ["north", "south"])
        #expect(model.slices[0].style.foregroundStyle == .series(ChartChannel(value: .string("North"), label: "Region")))
        #expect(model.selection == PieSelectionBinding(value: "north", onChangeId: "selectRegion"))
    }

    @Test func rejectsInvalidTierTwoCartesianMarks() throws {
        let chart = try chart([
            Directive(type: "RuleMark", props: ["x": ["value": "Jan"], "y": ["value": 10]]),
            Directive(type: "RectangleMark", props: ["x": ["value": "Jan"]])
        ])

        let model = ChartCollector.collect(chart: chart)

        #expect(model.marks.isEmpty)
        #expect(model.diagnostics.contains { $0.severity == .error && $0.message.contains("RuleMark requires exactly one of x or y") })
        #expect(model.diagnostics.contains { $0.severity == .error && $0.message.contains("RectangleMark requires x and y channels") })
    }
}

private let chartFixtureNames = [
    "bar-single-series",
    "bar-multi-series",
    "bar-stacked",
    "line-single",
    "line-multi-series",
    "line-with-points",
    "area-stacked",
    "line-with-rule",
    "hidden-axis",
    "custom-domain",
    "legend-hidden",
    "interpolation-monotone",
    "accessibility-labeled",
    "x-rule-reference",
    "heatmap-cells",
    "rectangle-ranges",
    "axis-explicit-values",
    "axis-formatter-currency",
    "axis-grid-tick-hidden",
    "point-symbols",
    "symbol-scale-series",
    "mark-text-annotation",
    "x-selection-controlled"
]

private let pieFixtureNames = [
    "pie-basic",
    "pie-color-scale",
    "donut-basic",
    "pie-legend-hidden",
    "pie-accessibility-labeled",
    "pie-selection-controlled"
]

private let allChartFixtureNames = chartFixtureNames + pieFixtureNames

private struct ChartFixtureRoot {
    var name: String
    var root: Component
}

private func chartFixtureRoots() throws -> [ChartFixtureRoot] {
    [
        ChartFixtureRoot(
            name: "bar-single-series",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12),
                bar(x: "Feb", y: 18)
            ]))
        ),
        ChartFixtureRoot(
            name: "bar-multi-series",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12).modifier(Directive(type: "foregroundStyle", props: ["by": "North", "label": "Region"])),
                bar(x: "Jan", y: 9).modifier(Directive(type: "foregroundStyle", props: ["by": "South", "label": "Region"]))
            ])
            .modifier(Directive(type: "chartForegroundStyleScale", props: ["North": "blue", "South": "green"])))
        ),
        ChartFixtureRoot(
            name: "bar-stacked",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12, stacking: "standard").modifier(Directive(type: "foregroundStyle", props: ["by": "North"])),
                bar(x: "Jan", y: 9, stacking: "standard").modifier(Directive(type: "foregroundStyle", props: ["by": "South"]))
            ]))
        ),
        ChartFixtureRoot(
            name: "line-single",
            root: try component(Directive(type: "Chart", children: [
                line(x: "2026-01-01", y: 12),
                line(x: "2026-02-01", y: 15)
            ]).modifier(Directive(type: "chartXScale", props: ["type": "date"])))
        ),
        ChartFixtureRoot(
            name: "line-multi-series",
            root: try component(Directive(type: "Chart", children: [
                line(x: "2026-01-01", y: 12).modifier(Directive(type: "foregroundStyle", props: ["by": "North"])),
                line(x: "2026-01-01", y: 8).modifier(Directive(type: "foregroundStyle", props: ["by": "South"]))
            ]).modifier(Directive(type: "chartXScale", props: ["type": "date"])))
        ),
        ChartFixtureRoot(
            name: "line-with-points",
            root: try component(Directive(type: "Chart", children: [
                line(x: "2026-01-01", y: 12),
                point(x: "2026-01-01", y: 12),
                line(x: "2026-02-01", y: 15),
                point(x: "2026-02-01", y: 15)
            ]))
        ),
        ChartFixtureRoot(
            name: "area-stacked",
            root: try component(Directive(type: "Chart", children: [
                area(x: "2026-01-01", y: 12, stacking: "standard").modifier(Directive(type: "foregroundStyle", props: ["by": "North"])),
                area(x: "2026-01-01", y: 9, stacking: "standard").modifier(Directive(type: "foregroundStyle", props: ["by": "South"]))
            ]))
        ),
        ChartFixtureRoot(
            name: "line-with-rule",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12),
                line(x: "Feb", y: 18),
                rule(y: 15).modifier(Directive(type: "lineStyle", props: ["dash": [4, 2]]))
            ]))
        ),
        ChartFixtureRoot(
            name: "hidden-axis",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12),
                line(x: "Feb", y: 18)
            ]).modifier(Directive(type: "chartXAxis", props: ["hidden": true])))
        ),
        ChartFixtureRoot(
            name: "custom-domain",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 42),
                bar(x: "Feb", y: 64)
            ]).modifier(Directive(type: "chartYScale", props: ["domain": [0, 100]])))
        ),
        ChartFixtureRoot(
            name: "legend-hidden",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12).modifier(Directive(type: "foregroundStyle", props: ["by": "North"])),
                bar(x: "Jan", y: 9).modifier(Directive(type: "foregroundStyle", props: ["by": "South"]))
            ]).modifier(Directive(type: "chartLegend", props: ["hidden": true])))
        ),
        ChartFixtureRoot(
            name: "interpolation-monotone",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12).modifier(Directive(type: "interpolationMethod", props: ["rawValue": "monotone"])),
                line(x: "Feb", y: 18).modifier(Directive(type: "interpolationMethod", props: ["rawValue": "monotone"]))
            ]))
        ),
        ChartFixtureRoot(
            name: "accessibility-labeled",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12).modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "January revenue"]))
            ])
            .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "Revenue by month"]))
            .modifier(Directive(type: "accessibilityHint", props: ["rawValue": "Bar chart of monthly revenue"])))
        ),
        ChartFixtureRoot(
            name: "x-rule-reference",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12),
                bar(x: "Feb", y: 18),
                Directive(type: "RuleMark", props: ["x": ["value": "Feb", "label": "Release"]])
                    .modifier(Directive(type: "foregroundStyle", props: ["rawValue": "red"]))
                    .modifier(Directive(type: "lineStyle", props: ["dash": [4, 2]]))
            ]))
        ),
        ChartFixtureRoot(
            name: "heatmap-cells",
            root: try component(Directive(type: "Chart", children: [
                rectangle(x: "Jan", y: "North").modifier(Directive(type: "foregroundStyle", props: ["by": "High", "label": "Intensity"])),
                rectangle(x: "Feb", y: "South").modifier(Directive(type: "foregroundStyle", props: ["by": "Low", "label": "Intensity"]))
            ])
            .modifier(Directive(type: "chartForegroundStyleScale", props: ["High": "red", "Low": "blue"])))
        ),
        ChartFixtureRoot(
            name: "rectangle-ranges",
            root: try component(Directive(type: "Chart", children: [
                rectangle(x: "Jan", y: "North", x2: "Feb", y2: "South").modifier(Directive(type: "foregroundStyle", props: ["rawValue": "blue"])),
                rectangle(x: "Feb", y: "South", x2: "Mar", y2: "West").modifier(Directive(type: "foregroundStyle", props: ["rawValue": "green"]))
            ]))
        ),
        ChartFixtureRoot(
            name: "axis-explicit-values",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12),
                line(x: "Feb", y: 18),
                line(x: "Mar", y: 14)
            ])
            .modifier(Directive(type: "chartXAxis", props: [
                "values": ["Jan", "Feb", "Mar"],
                "position": "top"
            ])))
        ),
        ChartFixtureRoot(
            name: "axis-formatter-currency",
            root: try component(Directive(type: "Chart", children: [
                bar(x: "Jan", y: 12),
                bar(x: "Feb", y: 18)
            ])
            .modifier(Directive(type: "chartYAxis", props: [
                "formatter": ["style": "currency", "currency": "USD", "maximumFractionDigits": 0]
            ])))
        ),
        ChartFixtureRoot(
            name: "axis-grid-tick-hidden",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12),
                line(x: "Feb", y: 18)
            ])
            .modifier(Directive(type: "chartXAxis", props: ["ticksHidden": true, "gridHidden": true]))
            .modifier(Directive(type: "chartYAxis", props: ["labelsHidden": true])))
        ),
        ChartFixtureRoot(
            name: "point-symbols",
            root: try component(Directive(type: "Chart", children: [
                point(x: "Jan", y: 12)
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "North", "label": "Region"]))
                    .modifier(Directive(type: "symbol", props: ["rawValue": "diamond"]))
                    .modifier(Directive(type: "symbolSize", props: ["rawValue": 96]))
                    .modifier(Directive(type: "annotation", props: ["text": "Peak", "position": "top"]))
            ])
            .modifier(Directive(type: "chartSymbolScale", props: ["North": "diamond"])))
        ),
        ChartFixtureRoot(
            name: "symbol-scale-series",
            root: try component(Directive(type: "Chart", children: [
                point(x: "Jan", y: 10).modifier(Directive(type: "foregroundStyle", props: ["by": "circle", "label": "Symbol"])),
                point(x: "Feb", y: 12).modifier(Directive(type: "foregroundStyle", props: ["by": "square", "label": "Symbol"])),
                point(x: "Mar", y: 14).modifier(Directive(type: "foregroundStyle", props: ["by": "diamond", "label": "Symbol"])),
                point(x: "Apr", y: 16).modifier(Directive(type: "foregroundStyle", props: ["by": "triangle", "label": "Symbol"])),
                point(x: "May", y: 18).modifier(Directive(type: "foregroundStyle", props: ["by": "plus", "label": "Symbol"])),
                point(x: "Jun", y: 20).modifier(Directive(type: "foregroundStyle", props: ["by": "cross", "label": "Symbol"]))
            ])
            .modifier(Directive(type: "chartSymbolScale", props: [
                "circle": "circle",
                "square": "square",
                "diamond": "diamond",
                "triangle": "triangle",
                "plus": "plus",
                "cross": "cross"
            ])))
        ),
        ChartFixtureRoot(
            name: "mark-text-annotation",
            root: try component(Directive(type: "Chart", children: [
                line(x: "Jan", y: 12),
                point(x: "Feb", y: 18).modifier(Directive(type: "annotation", props: ["text": "Peak", "position": "top"]))
            ]))
        ),
        ChartFixtureRoot(
            name: "x-selection-controlled",
            root: try component(Directive(type: "Chart", children: [
                point(x: "Jan", y: 12),
                point(x: "Feb", y: 18)
            ])
            .modifier(Directive(type: "chartXSelection", props: ["value": "Jan", "onChangeId": "selectMonth"])))
        ),
        ChartFixtureRoot(
            name: "pie-basic",
            root: try component(Directive(type: "PieChart", children: [
                pieSlice(id: "product", value: 45, label: "Product"),
                pieSlice(id: "services", value: 35, label: "Services"),
                pieSlice(id: "support", value: 20, label: "Support")
            ]))
        ),
        ChartFixtureRoot(
            name: "pie-color-scale",
            root: try component(Directive(type: "PieChart", children: [
                pieSlice(id: "product", value: 45, label: "Product")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "Product"])),
                pieSlice(id: "services", value: 35, label: "Services")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "Services"])),
                pieSlice(id: "support", value: 20, label: "Support")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "Support"]))
            ])
            .modifier(Directive(type: "chartForegroundStyleScale", props: [
                "Product": "blue",
                "Services": "green",
                "Support": "orange"
            ])))
        ),
        ChartFixtureRoot(
            name: "donut-basic",
            root: try component(Directive(type: "PieChart", props: ["innerRadius": 0.55], children: [
                pieSlice(id: "north", value: 40, label: "North"),
                pieSlice(id: "south", value: 25, label: "South"),
                pieSlice(id: "west", value: 35, label: "West")
            ]))
        ),
        ChartFixtureRoot(
            name: "pie-legend-hidden",
            root: try component(Directive(type: "PieChart", children: [
                pieSlice(id: "north", value: 40, label: "North")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "North"])),
                pieSlice(id: "south", value: 60, label: "South")
                    .modifier(Directive(type: "foregroundStyle", props: ["by": "South"]))
            ])
            .modifier(Directive(type: "chartForegroundStyleScale", props: ["North": "blue", "South": "green"]))
            .modifier(Directive(type: "chartLegend", props: ["hidden": true])))
        ),
        ChartFixtureRoot(
            name: "pie-accessibility-labeled",
            root: try component(Directive(type: "PieChart", children: [
                pieSlice(id: "product", value: 45, label: "Product")
                    .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "Product revenue share"]))
                    .modifier(Directive(type: "accessibilityValue", props: ["rawValue": "45 percent"])),
                pieSlice(id: "services", value: 35, label: "Services")
                    .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "Services revenue share"]))
                    .modifier(Directive(type: "accessibilityValue", props: ["rawValue": "35 percent"]))
            ])
            .modifier(Directive(type: "accessibilityLabel", props: ["rawValue": "Revenue share"]))
            .modifier(Directive(type: "accessibilityHint", props: ["rawValue": "Pie chart of revenue by business line"])))
        ),
        ChartFixtureRoot(
            name: "pie-selection-controlled",
            root: try component(Directive(type: "PieChart", children: [
                pieSlice(id: "product", value: 45, label: "Product"),
                pieSlice(id: "services", value: 35, label: "Services"),
                pieSlice(id: "support", value: 20, label: "Support")
            ])
            .modifier(Directive(type: "chartSelection", props: ["value": "product", "onChangeId": "selectSlice"])))
        )
    ]
}

private func chart(_ children: [Directive]) throws -> ChartComponent {
    try #require(component(Directive(type: "Chart", children: children)) as? ChartComponent)
}

private func component(_ directive: Directive) throws -> Component {
    try #require(makeComponent(directive))
}

private func bar(x: Any, y: Any, stacking: String? = nil) -> Directive {
    var props: [String: Any] = ["x": ["value": x], "y": ["value": y]]
    if let stacking {
        props["stacking"] = stacking
    }
    return Directive(type: "BarMark", props: props)
}

private func line(x: Any, y: Any) -> Directive {
    Directive(type: "LineMark", props: ["x": ["value": x], "y": ["value": y]])
}

private func area(x: Any, y: Any, stacking: String? = nil) -> Directive {
    var props: [String: Any] = ["x": ["value": x], "y": ["value": y]]
    if let stacking {
        props["stacking"] = stacking
    }
    return Directive(type: "AreaMark", props: props)
}

private func point(x: Any, y: Any) -> Directive {
    Directive(type: "PointMark", props: ["x": ["value": x], "y": ["value": y]])
}

private func rule(y: Any) -> Directive {
    Directive(type: "RuleMark", props: ["y": ["value": y]])
}

private func rectangle(x: Any, y: Any, x2: Any? = nil, y2: Any? = nil) -> Directive {
    var props: [String: Any] = ["x": ["value": x], "y": ["value": y]]
    if let x2 {
        props["x2"] = ["value": x2]
    }
    if let y2 {
        props["y2"] = ["value": y2]
    }
    return Directive(type: "RectangleMark", props: props)
}

private func pieSlice(id: String? = nil, value: Any, label: String? = nil) -> Directive {
    var props: [String: Any] = ["value": value]
    if let id {
        props["id"] = id
    }
    if let label {
        props["label"] = label
    }
    return Directive(type: "PieSliceMark", props: props)
}
