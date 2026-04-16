import Foundation

/// Bridge that exposes a host's MCP capabilities to BindJS components running
/// in the embedded JavaScript runtime. Mirrors the upstream `MCPHost` TS
/// interface (`metabind-cms/packages/composejs-renderer/types/metabind.d.ts`).
///
/// Renderers conform to this protocol and pass an instance to
/// `BindJSContext.setMCPHost(_:)`, which proxies the methods into the JS
/// `runtime.mcpHost` object that `useMCPHost()` returns.
public protocol MCPHostBridge: AnyObject {
    // MARK: - Transport

    func sendRequest(method: String, params: [String: Any]) async throws -> Any?
    func sendNotification(method: String, params: [String: Any])

    // MARK: - Tool calls

    func toolCall(name: String, arguments: [String: Any]) async throws -> Any?

    // MARK: - Messaging

    func sendMessage(_ message: String) async throws

    // MARK: - Model context

    func updateModelContext(_ content: [String: Any]) async throws

    // MARK: - Size

    func sizeChanged(height: Double)

    // MARK: - Navigation

    func openLink(_ url: URL) async throws

    // MARK: - Display

    func requestDisplayMode(_ mode: String) async throws

    // MARK: - Logging

    func log(level: String, message: String, data: [String: Any]?)
}

// MARK: - Default implementations

public extension MCPHostBridge {
    func sendRequest(method: String, params: [String: Any]) async throws -> Any? { nil }
    func sendNotification(method: String, params: [String: Any]) {}
    func toolCall(name: String, arguments: [String: Any]) async throws -> Any? { nil }
    func sendMessage(_ message: String) async throws {}
    func updateModelContext(_ content: [String: Any]) async throws {}
    func sizeChanged(height: Double) {}
    func openLink(_ url: URL) async throws {}
    func requestDisplayMode(_ mode: String) async throws {}
    func log(level: String, message: String, data: [String: Any]?) {}
}
