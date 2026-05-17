import Charts
import SwiftUI

struct ChartMarkContent: ChartContent {
    let model: ChartModel

    var body: some ChartContent {
        ForEach(model.marks) { mark in
            ChartMarkContentDispatch(mark: mark)
        }
    }
}

private struct ChartMarkContentDispatch: ChartContent {
    let mark: ChartMark

    @ChartContentBuilder
    var body: some ChartContent {
        switch mark.kind {
        case .bar:
            renderBar(mark)
        case .line:
            renderLine(mark)
        case .area:
            renderArea(mark)
        case .point:
            renderPoint(mark)
        case .rule:
            renderRule(mark)
        case .rectangle:
            renderRectangle(mark)
        }
    }
}

private func renderBar(_ mark: ChartMark) -> AnyChartContent {
    if let x = mark.channels.x, let y = mark.channels.y {
        switch (x.value, y.value) {
        case (.string(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledBar(BarMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        case (.number(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledBar(BarMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        case (.number(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: styledBar(BarMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        case (.string(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: styledBar(BarMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

private func renderLine(_ mark: ChartMark) -> AnyChartContent {
    if let x = mark.channels.x, let y = mark.channels.y {
        switch (x.value, y.value) {
        case (.string(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledLine(LineMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.number(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledLine(LineMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

private func renderArea(_ mark: ChartMark) -> AnyChartContent {
    if let x = mark.channels.x, let y = mark.channels.y {
        switch (x.value, y.value) {
        case (.string(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledArea(AreaMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        case (.number(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledArea(AreaMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue), stacking: mark.stacking), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

private func renderPoint(_ mark: ChartMark) -> AnyChartContent {
    if let x = mark.channels.x, let y = mark.channels.y {
        switch (x.value, y.value) {
        case (.string(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledPoint(PointMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.number(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: styledPoint(PointMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.number(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: styledPoint(PointMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.string(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: styledPoint(PointMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

private func renderRule(_ mark: ChartMark) -> AnyChartContent {
    if let y = mark.channels.y {
        switch y.value {
        case .number(let yValue):
            return AnyChartContent(erasing: styledRule(RuleMark(y: .value(y.label ?? "y", yValue)), mark: mark))
        case .string(let yValue):
            return AnyChartContent(erasing: styledRule(RuleMark(y: .value(y.label ?? "y", yValue)), mark: mark))
        case .bool:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    } else if let x = mark.channels.x {
        switch x.value {
        case .number(let xValue):
            return AnyChartContent(erasing: styledRule(RuleMark(x: .value(x.label ?? "x", xValue)), mark: mark))
        case .string(let xValue):
            return AnyChartContent(erasing: styledRule(RuleMark(x: .value(x.label ?? "x", xValue)), mark: mark))
        case .bool:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

private func renderRectangle(_ mark: ChartMark) -> AnyChartContent {
    if let x = mark.channels.x, let y = mark.channels.y, let x2 = mark.channels.x2, let y2 = mark.channels.y2 {
        switch (x.value, x2.value, y.value, y2.value) {
        case (.string(let xValue), .string(let x2Value), .string(let yValue), .string(let y2Value)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(xStart: .value(x.label ?? "x", xValue), xEnd: .value(x2.label ?? "x2", x2Value), yStart: .value(y.label ?? "y", yValue), yEnd: .value(y2.label ?? "y2", y2Value)), mark: mark))
        case (.string(let xValue), .string(let x2Value), .number(let yValue), .number(let y2Value)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(xStart: .value(x.label ?? "x", xValue), xEnd: .value(x2.label ?? "x2", x2Value), yStart: .value(y.label ?? "y", yValue), yEnd: .value(y2.label ?? "y2", y2Value)), mark: mark))
        case (.number(let xValue), .number(let x2Value), .number(let yValue), .number(let y2Value)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(xStart: .value(x.label ?? "x", xValue), xEnd: .value(x2.label ?? "x2", x2Value), yStart: .value(y.label ?? "y", yValue), yEnd: .value(y2.label ?? "y2", y2Value)), mark: mark))
        case (.number(let xValue), .number(let x2Value), .string(let yValue), .string(let y2Value)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(xStart: .value(x.label ?? "x", xValue), xEnd: .value(x2.label ?? "x2", x2Value), yStart: .value(y.label ?? "y", yValue), yEnd: .value(y2.label ?? "y2", y2Value)), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    } else if let x = mark.channels.x, let y = mark.channels.y {
        switch (x.value, y.value) {
        case (.string(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.string(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.number(let xValue), .number(let yValue)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        case (.number(let xValue), .string(let yValue)):
            return AnyChartContent(erasing: foregroundStyled(RectangleMark(x: .value(x.label ?? "x", xValue), y: .value(y.label ?? "y", yValue)), mark: mark))
        default:
            return AnyChartContent(erasing: EmptyChartContent())
        }
    }

    return AnyChartContent(erasing: EmptyChartContent())
}

@ChartContentBuilder
private func styledBar<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    let rounded = mark.style.cornerRadius.map { content.cornerRadius($0) }
    if let rounded {
        foregroundStyled(rounded, mark: mark)
    } else {
        foregroundStyled(content, mark: mark)
    }
}

@ChartContentBuilder
private func styledLine<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    let lined = mark.style.lineStyle.map { content.lineStyle($0.strokeStyle) }
    if let lined {
        interpolated(lined, mark: mark)
    } else {
        interpolated(content, mark: mark)
    }
}

@ChartContentBuilder
private func styledArea<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    interpolated(content, mark: mark)
}

@ChartContentBuilder
private func styledPoint<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    let sized = mark.style.symbolSize.map { content.symbolSize($0) }
    if let sized {
        foregroundStyled(symbolStyled(accessibilityStyled(sized, mark: mark), mark: mark), mark: mark)
    } else {
        foregroundStyled(symbolStyled(accessibilityStyled(content, mark: mark), mark: mark), mark: mark)
    }
}

@ChartContentBuilder
private func styledRule<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    let lined = mark.style.lineStyle.map { content.lineStyle($0.strokeStyle) }
    if let lined {
        foregroundStyled(accessibilityStyled(lined, mark: mark), mark: mark)
    } else {
        foregroundStyled(accessibilityStyled(content, mark: mark), mark: mark)
    }
}

@ChartContentBuilder
private func interpolated<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    if let interpolation = mark.style.interpolationMethod {
        foregroundStyled(accessibilityStyled(content.interpolationMethod(interpolation.chartsInterpolation), mark: mark), mark: mark)
    } else {
        foregroundStyled(accessibilityStyled(content, mark: mark), mark: mark)
    }
}

@ChartContentBuilder
private func foregroundStyled<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    switch mark.style.foregroundStyle {
    case .color(let color):
        accessibilityStyled(content.foregroundStyle(Color.chartColor(named: color)), mark: mark)
    case .series(let channel):
        switch channel.value {
        case .string(let value):
            accessibilityStyled(content.foregroundStyle(by: .value(channel.label ?? "Series", value)), mark: mark)
        case .number(let value):
            accessibilityStyled(content.foregroundStyle(by: .value(channel.label ?? "Series", value)), mark: mark)
        case .bool(let value):
            accessibilityStyled(content.foregroundStyle(by: .value(channel.label ?? "Series", value ? "true" : "false")), mark: mark)
        }
    case .none:
        accessibilityStyled(content, mark: mark)
    }
}

@ChartContentBuilder
private func accessibilityStyled<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    if let label = mark.accessibility.label, let value = mark.accessibility.value {
        annotated(content
            .accessibilityLabel(label)
            .accessibilityValue(value), mark: mark)
    } else if let label = mark.accessibility.label {
        annotated(content.accessibilityLabel(label), mark: mark)
    } else if let value = mark.accessibility.value {
        annotated(content.accessibilityValue(value), mark: mark)
    } else {
        annotated(content, mark: mark)
    }
}

@ChartContentBuilder
private func symbolStyled<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    switch mark.style.symbol {
    case .circle:
        content.symbol(BasicChartSymbolShape.circle)
    case .square:
        content.symbol(BasicChartSymbolShape.square)
    case .diamond:
        content.symbol(BasicChartSymbolShape.diamond)
    case .triangle:
        content.symbol(BasicChartSymbolShape.triangle)
    case .plus:
        content.symbol(BasicChartSymbolShape.plus)
    case .cross:
        content.symbol(BasicChartSymbolShape.cross)
    case .none:
        switch mark.style.foregroundStyle {
        case .series(let channel):
            switch channel.value {
            case .string(let value):
                content.symbol(by: .value(channel.label ?? "Symbol", value))
            case .number(let value):
                content.symbol(by: .value(channel.label ?? "Symbol", value))
            case .bool(let value):
                content.symbol(by: .value(channel.label ?? "Symbol", value ? "true" : "false"))
            }
        case .color, .none:
            content
        }
    }
}

@ChartContentBuilder
private func annotated<Content: ChartContent>(_ content: Content, mark: ChartMark) -> some ChartContent {
    if let annotation = mark.style.annotation {
        content.annotation(position: annotation.position.chartsPosition) {
            Text(annotation.text)
        }
    } else {
        content
    }
}

private extension ChartMark {
    var stacking: MarkStackingMethod {
        switch style.stacking {
        case .standard:
            return .standard
        case .unstacked:
            return .unstacked
        }
    }
}

private extension ChartLineStyle {
    var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: width ?? 2, dash: (dash ?? []).map { CGFloat($0) })
    }
}

private extension ChartMarkStyle.Interpolation {
    var chartsInterpolation: InterpolationMethod {
        switch self {
        case .linear:
            return .linear
        case .monotone:
            return .monotone
        case .cardinal:
            return .cardinal
        case .catmullRom:
            return .catmullRom
        case .stepStart:
            return .stepStart
        case .stepCenter:
            return .stepCenter
        case .stepEnd:
            return .stepEnd
        }
    }
}

private extension ChartAnnotation.Position {
    var chartsPosition: AnnotationPosition {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .overlay
        }
    }
}

private struct EmptyChartContent: ChartContent {
    var body: some ChartContent {}
}
