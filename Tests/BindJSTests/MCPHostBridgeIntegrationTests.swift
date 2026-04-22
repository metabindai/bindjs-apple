import Testing
import Foundation
import JavaScriptCore
@testable import BindJS

/// Integration tests for the Swift ↔ JS `MCPHostBridge` plumbing.
///
/// These exercise `BindJSContext.attachMCPHost` by instantiating a real
/// JSContext, attaching a recording Swift bridge, evaluating JS that calls
/// each host method, and verifying both sides see consistent state.
///
/// The tests intentionally skip the React-render pipeline — they just
/// speak to `runtime.mcpHost` directly, which is what `useMCPHost()`
/// returns inside components.
@Suite("MCPHostBridge JS integration")
struct MCPHostBridgeIntegrationTests {

    // MARK: - Recording bridge

    /// Records every invocation and returns configurable stub values.
    final class RecordingBridge: MCPHostBridge, @unchecked Sendable {
        struct Call: Sendable {
            let method: String
            let payload: String
        }

        private let lock = NSLock()
        private var _calls: [Call] = []

        var calls: [Call] { lock.withLock { _calls } }
        func record(_ call: Call) { lock.withLock { _calls.append(call) } }

        var toolCallResult: Any? = ["ok": true]
        var toolCallError: Error?
        var elicitResponse: ElicitationResponse = ElicitationResponse(action: .decline)
        var openLinkResult: Bool = true

        func sendRequest(method: String, params: [String: Any]) async throws -> Any? {
            record(.init(method: "sendRequest", payload: "\(method) \(stringify(params))"))
            return nil
        }
        func sendNotification(method: String, params: [String: Any]) {
            record(.init(method: "sendNotification", payload: "\(method) \(stringify(params))"))
        }
        func toolCall(name: String, arguments: [String: Any]) async throws -> Any? {
            record(.init(method: "toolCall", payload: "\(name) \(stringify(arguments))"))
            if let toolCallError { throw toolCallError }
            return toolCallResult
        }
        func sendMessage(_ message: String) async throws {
            record(.init(method: "sendMessage", payload: message))
        }
        func updateModelContext(_ content: [String: Any]) async throws {
            record(.init(method: "updateModelContext", payload: stringify(content)))
        }
        func elicit(schema: [String: Any], metadata: [String: Any]?) async throws -> ElicitationResponse {
            record(.init(method: "elicit", payload: "\(stringify(schema)) meta=\(metadata.map(stringify) ?? "nil")"))
            return elicitResponse
        }
        func sizeChanged(height: Double) {
            record(.init(method: "sizeChanged", payload: "\(height)"))
        }
        func openLink(_ url: URL) async throws {
            record(.init(method: "openLink", payload: url.absoluteString))
            if !openLinkResult {
                struct Refused: Error {}
                throw Refused()
            }
        }
        func requestDisplayMode(_ mode: String) async throws {
            record(.init(method: "requestDisplayMode", payload: mode))
        }
        func log(level: String, message: String, data: [String: Any]?) {
            record(.init(method: "log", payload: "\(level) \(message) \(data.map(stringify) ?? "nil")"))
        }

        private func stringify(_ dict: [String: Any]) -> String {
            guard
                let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
                let str = String(data: data, encoding: .utf8)
            else { return "<unencodable>" }
            return str
        }
    }

    // MARK: - Helpers

    @MainActor
    private func makeContext() -> BindJSContext { BindJSContext() }

    /// Run a script that returns a Promise; await the JS resolution and
    /// return the resolved value as a String (stringified) or nil if null.
    private func awaitPromise(_ context: BindJSContext, script: String, timeout: Duration = .seconds(2)) async throws -> String? {
        // Create a global `__probe__` that the script populates. Poll it
        // because the Promise resolves via JSContext dispatch.
        let wrapper = """
        (function() {
            globalThis.__probe__ = { status: 'pending' };
            (async () => {
                try {
                    const result = await (async () => { \(script) })();
                    globalThis.__probe__ = { status: 'ok', value: result };
                } catch (e) {
                    globalThis.__probe__ = { status: 'error', message: String(e) };
                }
            })();
            return true;
        })()
        """
        await MainActor.run {
            _ = context.evaluate(wrapper)
        }

        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            let status: String? = await MainActor.run { context.evaluate("globalThis.__probe__ && globalThis.__probe__.status") }
            if status == "ok" {
                return await MainActor.run {
                    context.evaluate("JSON.stringify(globalThis.__probe__.value)")
                }
            }
            if status == "error" {
                let msg = await MainActor.run { context.evaluate("globalThis.__probe__.message") } ?? "unknown"
                throw IntegrationError.promiseRejected(msg)
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        throw IntegrationError.timeout
    }

    enum IntegrationError: Error {
        case promiseRejected(String)
        case timeout
    }

    // MARK: - toolCall

    @Test func toolCallRoundTrip() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        bridge.toolCallResult = ["total": 3, "items": ["a", "b", "c"]]
        await context.setMCPHost(bridge)

        let resultJSON = try await awaitPromise(
            context,
            script: "return await runtime.mcpHost.toolCall('search', {q: 'sofa', limit: 3});"
        )

        // Swift side received the call with the right args.
        let calls = bridge.calls
        #expect(calls.count == 1)
        #expect(calls.first?.method == "toolCall")
        #expect(calls.first?.payload.contains("search") == true)
        #expect(calls.first?.payload.contains("\"q\":\"sofa\"") == true)

        // JS side got the stubbed return value back.
        let parsed = try JSONSerialization.jsonObject(with: Data((resultJSON ?? "").utf8)) as? [String: Any]
        #expect(parsed?["total"] as? Int == 3)
    }

    @Test func toolCallRejectsOnSwiftError() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        struct Boom: Error, LocalizedError { var errorDescription: String? { "intentional" } }
        bridge.toolCallError = Boom()
        await context.setMCPHost(bridge)

        do {
            _ = try await awaitPromise(
                context,
                script: "return await runtime.mcpHost.toolCall('x', {});"
            )
            Issue.record("expected rejection")
        } catch let IntegrationError.promiseRejected(msg) {
            #expect(msg.contains("intentional"))
        }
    }

    // MARK: - sendMessage / sendNotification / log

    @Test func sendMessageForwards() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = try await awaitPromise(
            context,
            script: "await runtime.mcpHost.sendMessage('hi from JS'); return true;"
        )

        let call = bridge.calls.first { $0.method == "sendMessage" }
        #expect(call?.payload == "hi from JS")
    }

    @Test func sendNotificationForwards() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = await MainActor.run {
            context.evaluate("runtime.mcpHost.sendNotification('notifications/message', { level: 'info', message: 'hi' })")
        }
        // sendNotification is sync — synchronously recorded. But JSContext
        // block invocation bounces via Swift convention(block); wait briefly.
        try await Task.sleep(for: .milliseconds(30))

        let call = bridge.calls.first { $0.method == "sendNotification" }
        #expect(call != nil)
        #expect(call?.payload.contains("notifications/message") == true)
    }

    @Test func logForwardsWithData() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = await MainActor.run {
            context.evaluate("runtime.mcpHost.log('warning', 'watch out', { code: 42 })")
        }
        try await Task.sleep(for: .milliseconds(30))

        let call = bridge.calls.first { $0.method == "log" }
        #expect(call?.payload.hasPrefix("warning watch out") == true)
        #expect(call?.payload.contains("\"code\":42") == true)
    }

    // MARK: - updateModelContext

    @Test func updateModelContextRoundTrip() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = try await awaitPromise(
            context,
            script: "await runtime.mcpHost.updateModelContext({ selectedColor: 'oat', qty: 2 }); return true;"
        )

        let call = bridge.calls.first { $0.method == "updateModelContext" }
        #expect(call?.payload.contains("\"selectedColor\":\"oat\"") == true)
        #expect(call?.payload.contains("\"qty\":2") == true)
    }

    // MARK: - elicit

    @Test func elicitRoundTripAccept() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        bridge.elicitResponse = ElicitationResponse(
            action: .accept,
            content: ["email": "a@b.com"]
        )
        await context.setMCPHost(bridge)

        let resultJSON = try await awaitPromise(
            context,
            script: "return await runtime.mcpHost.elicit({type: 'object'}, {title: 'Sign up'});"
        )

        let parsed = try JSONSerialization.jsonObject(with: Data((resultJSON ?? "").utf8)) as? [String: Any]
        #expect(parsed?["action"] as? String == "accept")
        let content = parsed?["content"] as? [String: Any]
        #expect(content?["email"] as? String == "a@b.com")
    }

    @Test func elicitRoundTripDecline() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        bridge.elicitResponse = ElicitationResponse(action: .decline)
        await context.setMCPHost(bridge)

        let resultJSON = try await awaitPromise(
            context,
            script: "return await runtime.mcpHost.elicit({type: 'object'}, null);"
        )

        let parsed = try JSONSerialization.jsonObject(with: Data((resultJSON ?? "").utf8)) as? [String: Any]
        #expect(parsed?["action"] as? String == "decline")
        #expect(parsed?["content"] == nil)
    }

    // MARK: - openLink / requestDisplayMode / sizeChanged

    @Test func openLinkHandledResolves() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        bridge.openLinkResult = true
        await context.setMCPHost(bridge)

        _ = try await awaitPromise(
            context,
            script: "await runtime.mcpHost.openLink('https://example.com/page'); return true;"
        )

        let call = bridge.calls.first { $0.method == "openLink" }
        #expect(call?.payload == "https://example.com/page")
    }

    @Test func openLinkRefusedRejects() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        bridge.openLinkResult = false
        await context.setMCPHost(bridge)

        do {
            _ = try await awaitPromise(
                context,
                script: "await runtime.mcpHost.openLink('https://example.com'); return true;"
            )
            Issue.record("expected rejection")
        } catch IntegrationError.promiseRejected {
            // Expected.
        }
    }

    @Test func requestDisplayModeForwards() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = try await awaitPromise(
            context,
            script: "await runtime.mcpHost.requestDisplayMode('fullscreen'); return true;"
        )

        let call = bridge.calls.first { $0.method == "requestDisplayMode" }
        #expect(call?.payload == "fullscreen")
    }

    @Test func sizeChangedIsSynchronousNoOp() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)

        _ = await MainActor.run {
            context.evaluate("runtime.mcpHost.sizeChanged(400)")
        }
        try await Task.sleep(for: .milliseconds(30))

        let call = bridge.calls.first { $0.method == "sizeChanged" }
        #expect(call?.payload == "400.0")
    }

    // MARK: - Lifecycle

    @Test func setMCPHostNilDetaches() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)
        await context.setMCPHost(nil)

        let hasHost = await MainActor.run {
            context.evaluate("runtime.mcpHost === null || runtime.mcpHost === undefined")
        }
        #expect(hasHost == "true")
    }

    @Test func sameHostTwiceIsIdempotent() async throws {
        let context = await makeContext()
        let bridge = RecordingBridge()
        await context.setMCPHost(bridge)
        await context.setMCPHost(bridge)

        _ = try await awaitPromise(
            context,
            script: "return await runtime.mcpHost.toolCall('x', {});"
        )
        // Only one call should land (not duplicated because of re-attach).
        #expect(bridge.calls.filter { $0.method == "toolCall" }.count == 1)
    }
}

// MARK: - Test helpers

private extension BindJSContext {
    @MainActor
    func evaluate(_ script: String) -> String? {
        evaluateForTesting(script)
    }
}
