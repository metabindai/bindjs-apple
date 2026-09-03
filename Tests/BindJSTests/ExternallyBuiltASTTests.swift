import Foundation
import JavaScriptCore
import SwiftUI
import Testing
@testable import BindJS

/// Tests for the seam a host uses to render trees it built itself — an A2UI renderer, say —
/// inside the runtime `BindJSContext` already owns: `javaScriptContext` and
/// `view(id:buildingAST:)`.
@Suite("Externally built ASTs")
struct ExternallyBuiltASTTests {

    // MARK: - Fixtures

    private static let greeting = """
    exports.default = defineComponent({
        body: (props) => Text(props.name)
    })
    """

    // MARK: - javaScriptContext

    @Test func javaScriptContextHoldsTheRuntime() {
        let context = BindJSContext()

        // `runtime` is a `const` in the wrapper, so it lives in the global lexical
        // environment: evaluating its name is the only way a host can reach it.
        let runtime = context.javaScriptContext.evaluateScript("runtime")

        #expect(runtime?.isObject == true)
        #expect(runtime?.forProperty("registerComponent")?.isUndefined == false)
    }

    @Test func hostClosuresAreCallableFromJavaScript() {
        let context = BindJSContext()
        var received: String?

        let callback: @convention(block) (String) -> Void = { received = $0 }
        context.javaScriptContext.setObject(callback, forKeyedSubscript: "hostCallback" as NSString)
        context.javaScriptContext.evaluateScript("hostCallback('tapped')")

        #expect(received == "tapped")
    }

    // MARK: - view(id:buildingAST:)

    @Test func viewDecodesAnASTBuiltInsideTheClosure() {
        let context = BindJSContext()
        context.register(name: "Greeting", source: Self.greeting)
        var builderContext: JSContext?

        let view = context.view(id: "surface") { javaScriptContext in
            builderContext = javaScriptContext
            return javaScriptContext.evaluateScript("callComponent(['Greeting', { name: 'world' }])")
        }

        #expect(view != nil)
        #expect(builderContext === context.javaScriptContext)
    }

    @Test func viewIsNilWhenTheBuilderProducesNothing() {
        let context = BindJSContext()

        let view = context.view(id: "surface") { _ in nil }

        #expect(view == nil)
    }

    @Test func viewIsNilWhenTheASTIsNotADirective() {
        let context = BindJSContext()

        let view = context.view(id: "surface") { javaScriptContext in
            javaScriptContext.evaluateScript("({ notA: 'directive' })")
        }

        #expect(view == nil)
    }
}
