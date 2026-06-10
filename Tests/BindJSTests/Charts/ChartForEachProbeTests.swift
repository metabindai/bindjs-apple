import Foundation
import Testing
@testable import BindJS

@Suite("Chart numeric channel decoding")
struct ChartNumericChannelTests {
    /// JS numbers 0 and 1 arrive from JavaScriptCore as NSNumber, which
    /// Foundation will happily bridge to Bool. A bool-typed channel never
    /// renders, so `ForEach(data, (v, i) => LineMark({ x: i, ... }))` lost
    /// its first two points — every 0-indexed chart series started at x=2.
    @Test @MainActor func zeroAndOneIndicesDecodeAsNumbers() throws {
        let context = BindJSContext()
        context.register(
            name: "ForEachProbe",
            source: """
            const body = () => Chart({}, [
              ForEach([10, 20, 15, 30], (v, i) => LineMark({ x: i, y: v }))
            ]).chartXScale({ type: "linear", domain: [0, 3] });
            """
        )

        let component = try #require(context.componentForName("ForEachProbe"))
        let model = try #require(ChartCollector.collect(root: component))

        let xs = model.marks.compactMap { mark -> Double? in
            if case .number(let n) = mark.channels.x?.value { return n }
            return nil
        }
        let ys = model.marks.compactMap { mark -> Double? in
            if case .number(let n) = mark.channels.y?.value { return n }
            return nil
        }
        #expect(model.marks.count == 4)
        #expect(xs == [0, 1, 2, 3])
        #expect(ys == [10, 20, 15, 30])
    }

    @Test func chartValueKeepsBoolAndNumberDistinct() {
        #expect(ChartValue(true) == .bool(true))
        #expect(ChartValue(false) == .bool(false))
        #expect(ChartValue(NSNumber(value: true)) == .bool(true))
        #expect(ChartValue(0) == .number(0))
        #expect(ChartValue(1) == .number(1))
        #expect(ChartValue(NSNumber(value: 0)) == .number(0))
        #expect(ChartValue(NSNumber(value: 1)) == .number(1))
        #expect(ChartValue(1.5) == .number(1.5))
        #expect(ChartValue(Float(2)) == .number(2))
    }
}
