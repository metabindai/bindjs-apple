import SwiftUI
import Testing
@testable import BindJS

/// A frame that mixes fixed and flexible lengths sizes as SwiftUI does: the
/// fixed axis is exactly its length, the flexible axis follows the bounds.
@MainActor
@Suite("Flexible frames")
struct FlexibleFrameTests {

    private func size(_ props: [String: Any], proposal: ProposedViewSize) -> CGSize {
        let frame = FlexibleFrameComponent(from: Directive(type: "frame", props: props))!
        let renderer = ImageRenderer(content: Color.red.modifier(frame))
        renderer.proposedSize = proposal
        renderer.scale = 1
        let image = renderer.cgImage!
        return CGSize(width: image.width, height: image.height)
    }

    @Test func fixedHeightWithFullWidth() {
        // frame({ maxWidth: Infinity, height: 240 }): as wide as offered, 240pt tall.
        let props: [String: Any] = ["maxWidth": CGFloat.infinity, "height": CGFloat(240)]
        #expect(size(props, proposal: ProposedViewSize(width: 174, height: nil)) == CGSize(width: 174, height: 240))
        #expect(size(props, proposal: ProposedViewSize(width: 174, height: 600)) == CGSize(width: 174, height: 240))
    }

    @Test func fixedWidthWithHeightBounds() {
        // frame({ width: 100, minHeight: 50, maxHeight: 80 })
        let props: [String: Any] = ["width": CGFloat(100), "minHeight": CGFloat(50), "maxHeight": CGFloat(80)]
        #expect(size(props, proposal: ProposedViewSize(width: 300, height: 400)) == CGSize(width: 100, height: 80))
        #expect(size(props, proposal: ProposedViewSize(width: 300, height: 20)) == CGSize(width: 100, height: 50))
    }

    @Test func boundsAlone() {
        let props: [String: Any] = ["maxWidth": CGFloat(200)]
        #expect(size(props, proposal: ProposedViewSize(width: 300, height: 100)) == CGSize(width: 200, height: 100))
    }
}
