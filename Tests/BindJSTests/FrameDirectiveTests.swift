import Testing
@testable import BindJS

/// A `frame` directive that carries any min/max bound decodes to `FlexibleFrameComponent`.
/// A fixed `width` / `height` written alongside must survive that: A2UI's Video and
/// AudioPlayer are `frame({ maxWidth: Infinity, height: … })`, and an `AVPlayerViewController`
/// has no height of its own, so a dropped height collapses the player to nothing.
@Suite("Frame directives")
struct FrameDirectiveTests {

    @Test func flexibleFrameKeepsAFixedHeight() throws {
        let directive = Directive(type: "frame", props: ["maxWidth": Double.infinity, "height": 220.0])

        let frame = try #require(makeComponent(directive) as? FlexibleFrameComponent)

        #expect(frame.maxWidth == .infinity)
        #expect(frame.height == 220)
        #expect(frame.width == nil)
    }

    @Test func flexibleFrameKeepsAFixedWidth() throws {
        let directive = Directive(type: "frame", props: ["width": 120.0, "maxHeight": 300.0])

        let frame = try #require(makeComponent(directive) as? FlexibleFrameComponent)

        #expect(frame.width == 120)
        #expect(frame.maxHeight == 300)
    }

    @Test func fixedOnlyFrameIsStillAFixedFrame() {
        let directive = Directive(type: "frame", props: ["width": 40.0, "height": 40.0])

        #expect(makeComponent(directive) is FrameComponent)
    }
}
