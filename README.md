# BindJS for Apple

Native SwiftUI rendering engine for BindJS bundles on iOS, macOS, visionOS, watchOS, and tvOS.

BindJS lets server-authored components ship as a single compiled JavaScript bundle that describes a SwiftUI-shaped tree (VStack, Button, Image, AsyncImage, Charts, Model3D, and hundreds more). This package runs that JS inside a sandboxed JSContext and renders the result as real native SwiftUI — no WebView, no HTML, no layout approximations.

It's used by [metabind-ai-apple](https://github.com/yapstudios/metabind-ai-apple) to render interactive MCP tool results, but works standalone against any BindJS bundle.

## Requirements

- Swift 5.11+
- iOS 17 / macOS 14 / visionOS 1 / tvOS 13 / watchOS 6

## Install

```swift
.package(url: "https://github.com/yapstudios/bindjs-apple.git", from: "1.1.0"),
```

```swift
.target(name: "YourApp", dependencies: [
    .product(name: "BindJS", package: "bindjs-apple"),
])
```

## Quick start

```swift
import SwiftUI
import BindJS

struct ComponentView: View {
    let content: ResolvedContent   // compiled BindJS bundle
    let args: [String: Any]

    var body: some View {
        BindJSView(content: content, arguments: args)
    }
}
```

`BindJSView` evaluates the bundle, walks the component tree, and builds a native SwiftUI view graph. State, layout, animations, and gestures all run in SwiftUI — the JS side only produces declarative directives.

## useMCPHost — components talk to your app

A BindJS component can call host capabilities at runtime:

```js
const host = useMCPHost()
if (host) {
    const { products } = await host.toolCall('search_products', { query })
    await host.sendMessage('Tell me more about this one')
    await host.updateModelContext({ selected: products[0] })
    const response = await host.elicit(
        { type: 'object', properties: { email: { type: 'string' } } },
        { title: 'Sign up' }
    )
}
```

To serve these calls, conform to `MCPHostBridge` and attach via `BindJSConfiguration`:

```swift
final class MyHost: MCPHostBridge {
    func toolCall(name: String, arguments: [String: Any]) async throws -> Any? {
        try await myServer.call(name, arguments)
    }
    func sendMessage(_ message: String) async throws { … }
    func updateModelContext(_ content: [String: Any]) async throws { … }
    func elicit(schema: [String: Any], metadata: [String: Any]?) async throws -> ElicitationResponse { … }
    func openLink(_ url: URL) async throws { … }
    func log(level: String, message: String, data: [String: Any]?) { … }
}

BindJSView(content: content, arguments: args)
    .bindJS(BindJSConfiguration(mcpHost: MyHost()))
```

The protocol mirrors the TS [`MCPHost` interface](https://github.com/modelcontextprotocol/ext-apps) used by web hosts (Claude Desktop, ChatGPT, VS Code, etc.), plus a native-only `elicit` for request-input flows. Methods that don't apply on native (`sendRequest`, `sendNotification`, `sizeChanged`) have graceful no-op defaults, so components written against the web contract run unchanged.

For the full Metabind integration (conversation loop, tool rendering, agent proxy), see [metabind-ai-apple](https://github.com/yapstudios/metabind-ai-apple).

## Logging

JS exceptions and `console.log` / `console.warn` / `console.error` calls from components are routed through `os.Logger`:

| Subsystem | Category | Contents |
|---|---|---|
| `BindJS` | `Runtime` | JS exceptions (with stack), component `console.log` output |

Tail with `log show --predicate 'subsystem == "BindJS"' --info --debug --last 5m`.

## Distribution

BindJS is also published as a pre-built XCFramework at [bindjs-apple-binary](https://github.com/yapstudios/bindjs-apple-binary) for downstream apps that prefer a binary dependency. See that repo's README for the release process.

## License

MIT. See `LICENSE`.
