import SwiftUI
import Testing
@testable import BindJS

/// A frame that mixes fixed and flexible lengths sizes as a fixed frame inside
/// a flexible one, as SwiftUI's `.frame(width:height:).frame(minWidth:…)`.
@MainActor
@Suite("Flexible frames")
struct FlexibleFrameTests {

    /// The size SwiftUI gives `view` for `proposal`, in points.
    private func size(of view: some View, proposal: ProposedViewSize) -> CGSize {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = proposal
        var size = CGSize.zero
        renderer.render { rendered, _ in size = rendered }
        return size
    }

    private func frame(_ props: [String: Any]) -> FlexibleFrameComponent {
        FlexibleFrameComponent(from: Directive(type: "frame", props: props))!
    }

    @Test func fixedHeightWithFullWidth() {
        // frame({ maxWidth: Infinity, height: 240 }): as wide as offered, 240pt tall.
        let props: [String: Any] = ["maxWidth": CGFloat.infinity, "height": CGFloat(240)]
        let view = Color.red.modifier(frame(props))
        #expect(size(of: view, proposal: ProposedViewSize(width: 174, height: nil)) == CGSize(width: 174, height: 240))
        #expect(size(of: view, proposal: ProposedViewSize(width: 174, height: 600)) == CGSize(width: 174, height: 240))
    }

    @Test func fixedWidthWithHeightBounds() {
        let props: [String: Any] = ["width": CGFloat(100), "minHeight": CGFloat(50), "maxHeight": CGFloat(80)]
        let view = Color.red.modifier(frame(props))
        #expect(size(of: view, proposal: ProposedViewSize(width: 300, height: 400)) == CGSize(width: 100, height: 80))
        #expect(size(of: view, proposal: ProposedViewSize(width: 300, height: 20)) == CGSize(width: 100, height: 50))
    }

    @Test func boundsOnTheSameAxisApplyAroundTheFixedLength() {
        // Matches .frame(width: 100).frame(minWidth:/maxWidth:), the web and Android.
        let proposal = ProposedViewSize(width: 300, height: 100)
        for (props, expected) in [
            (["width": CGFloat(100), "maxWidth": CGFloat(50)], CGFloat(50)),
            (["width": CGFloat(100), "minWidth": CGFloat(200)], CGFloat(200)),
            (["width": CGFloat(100), "maxWidth": CGFloat(200)], CGFloat(200)),
        ] as [([String: Any], CGFloat)] {
            #expect(size(of: Color.red.modifier(frame(props)), proposal: proposal).width == expected)
        }
    }

    @Test func fixedLengthKeepsItsIdealSizeForText() {
        // With nothing proposed, wrapping text in a fixed width wraps at that width.
        let text = Text("Hello wide world with words that wrap")
        let reference = size(of: text.frame(width: 100).frame(maxHeight: .infinity), proposal: .unspecified)
        let actual = size(of: text.modifier(frame(["width": CGFloat(100), "maxHeight": CGFloat.infinity])), proposal: .unspecified)
        #expect(actual == reference)
        #expect(actual.width == 100)
        #expect(actual.height > 20)
    }

    @Test func boundsAlone() {
        #expect(size(of: Color.red.modifier(frame(["maxWidth": CGFloat(200)])), proposal: ProposedViewSize(width: 300, height: 100)) == CGSize(width: 200, height: 100))
    }
}
