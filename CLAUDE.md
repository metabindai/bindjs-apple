# MetabindUI Development Guide

## Build Commands
- Build package: `swift build`
- Run tests: `swift test`
- Run single test: `swift test --filter MetabindUITests/specificTestName`
- Generate Xcode project: `swift package generate-xcodeproj`

## Code Style Guidelines
- **Naming**: PascalCase for types (Component, View), camelCase for properties/methods
- **Protocols**: Use `Convertible` suffix for component conversion protocols
- **SwiftUI Pattern**: Follow SwiftUI modifier pattern (.frame, .padding) for component modifiers
- **Error Handling**: Use optionals/fallbacks instead of throwing errors upward
- **Imports**: Minimal imports (Foundation, SwiftUI only)
- **Documentation**: Document public APIs with comments explaining purpose
- **Architecture**: Protocol-oriented design with protocol extensions for shared functionality
- **Testing**: Create unit tests for new component types and modifiers

## File Layout

```
Sources/BindJS/
  Components/
    Views/          # View components (Button, Text, VStack, etc.)
    Modifiers/      # ViewModifier components (Padding, Frame, Animation, etc.)
  Visitors/
    ComponentVisitor.swift   # Visitor protocol + default implementations
  Core/
    Directive.swift          # Directive type (parsed JS tree nodes)
    JSAnimation.swift        # Animation types (internal access level)
  Resources/
    BindJSRuntime.js         # JS runtime — component/modifier registration
```

## Creating New Components

### Checklist

1. **Swift component** — `Sources/BindJS/Components/Views/` or `Modifiers/`
2. **ComponentVisitor** — `Sources/BindJS/Visitors/ComponentVisitor.swift` (protocol + default impl) — **always required**
3. **ComponentChildren** — `Sources/BindJS/Visitors/ComponentChildren.swift` — **only if component has child content**
4. **ComponentRewriter** — `Sources/BindJS/Visitors/ComponentRewriter.swift` — **only if component has child content**
5. **ComponentView** — `Sources/BindJS/Components/ComponentView.swift` (factory dict + switch case)
6. **JS Runtime** — `Sources/BindJS/Resources/BindJSRuntime.js` (registration)
7. **Type definitions** — `metabind-cms/packages/composejs-renderer/types/metabind.d.ts` (add to `Component` interface)
8. **Regenerate Monaco types** — `node metabind-cms/packages/metabind-editor/scripts/generateTypeDefinitions.js`
9. **Build** — `swift build` in bindjs-apple root

### Reference: Simple modifier (single primitive prop)

Use `OnChange` as the reference pattern. File: `Sources/BindJS/Components/Modifiers/OnChange.swift`

```swift
public struct ExampleComponent: Component {
    public static var directiveName: String = "example"
    public let value: String?
}

extension ExampleComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        value = directive["value"]  // Directive subscript handles String? extraction
    }

    public func accept<V>(visitor: inout V) -> V.Result where V: ComponentVisitor {
        visitor.visitExample(self)
    }
}

extension ExampleComponent: ViewModifier {
    public func body(content: Content) -> some View {
        content.someModifier(value)
    }
}
```

### Reference: Modifier with nested dict prop (e.g. animation config)

When a prop is a dict that maps to an internal `Decodable` type, use the JSON round-trip pattern:

```swift
if let dict: [String: Any] = directive["animation"],
   let data = try? JSONSerialization.data(withJSONObject: dict),
   let decoded = try? JSONDecoder().decode(JSAnimation.self, from: data) {
    animation = decoded
} else {
    animation = nil
}
```

### Directive subscript types

The `Directive` subscript supports these extractions:
- `directive["key"]` → `String?`, `Double?`, `Bool?`, `Int?` (any `ParsableArgument`)
- `directive["key"]` → `[String: Any]?` (nested dict)
- `directive["key"]` → `Directive?` (nested directive/component)
- `directive["key"]` → `[Directive]` (child directives array, defaults to `[]`)

### Visitor system (3 files, not 1)

There are three visitor-related protocols. **All components** need step 1. Steps 2–3 are only needed for components with child content.

#### 1. `ComponentVisitor.swift` — always required

Add both the protocol method and default implementation:

```swift
// In the protocol (Modifier Components section, alphabetical):
mutating func visitExample(_ example: ExampleComponent) -> Result

// In the extension (Modifier Components Default Implementations section):
mutating func visitExample(_ example: ExampleComponent) -> Result {
    return defaultVisit(example)
}
```

#### 2. `ComponentChildren.swift` — only if component has child content

`ComponentChildren` returns the child components for tree traversal. Override only if the component holds other `Component` references (children, content, label, etc.).

```swift
// Example: component with a `content` child
mutating func visitExample(_ example: ExampleComponent) -> [any Component] {
    [example.content]
}
// Example: component with a `children` array
mutating func visitExample(_ example: ExampleComponent) -> [any Component] {
    example.children
}
```

**Leaf components** (no child components, only primitive props like String/Bool/Double) — skip this. `defaultVisit` returns `[]`.

#### 3. `ComponentRewriter.swift` — only if component has child content

`ComponentRewriter` recursively rewrites the tree. Override only for components with children so the rewriter descends.

```swift
mutating func visitExample(_ example: ExampleComponent) -> Component {
    var copy = example
    copy.children = example.children.map { $0.accept(visitor: &self) }
    return copy
}
```

**Leaf components** — skip this. `defaultVisit` returns the component unchanged.

#### Decision rule

| Component has... | ComponentVisitor | ComponentChildren | ComponentRewriter |
|---|---|---|---|
| Only primitive props | Add visit method | Skip | Skip |
| Child `Component` refs | Add visit method | Add override | Add override |

### ComponentView.swift changes

Two edits in `ComponentView.swift`:

```swift
// 1. Factory dict (Modifiers section, alphabetical):
ExampleComponent.directiveName: { ExampleComponent(from: $0) },

// 2. ComponentViewModifier.body switch (alphabetical):
case let m as ExampleComponent: content.modifier(m)
```

For **views** (not modifiers), add to `ComponentView.body` switch instead:
```swift
case let example as ExampleComponent: example
```

### JS Runtime: Views vs Modifiers

**Views** — add to `componentNames` array (recognized automatically by `GenericComponent`):
```javascript
// No custom handler needed for most views
```

**Modifiers** — most use `GenericModifier` (args become props by name). Register only when custom handling is needed.

**When to write a custom modifier handler:**
- Args have different semantics (e.g., animation object + primitive value)
- Need to extract nested props from a component object (`.props`)
- Need to stringify or transform values before passing to Swift
- `GenericModifier` would mangle the args (wrong prop names, wrong structure)

**Custom modifier handler pattern:**
```javascript
function ExampleViewModifier({ args, name }) {
    return {
        props: {
            someObject: args[0]?.props ?? null,  // Extract inner component's props
            value: args[1] != null ? String(args[1]) : null  // Stringify for equatable
        }
    };
}
// Register: this.#registerBuiltInModifier('example', ExampleViewModifier);
```

**Existing custom handlers as reference:**
- `AnimationViewModifier` — animation object + observed value
- `OnHandler` — callback registration (onTapGesture, onChange, etc.)
- `SheetModifier` — complex props with isPresented/content/onDismiss
- `ContentModifier` — child content extraction (background, overlay, toolbar)

**Existing `AnimationModifier`** (for `.delay()`, `.speed()` on animation objects) is unrelated to the `.animation()` view modifier — different purpose, different handler.

### Type definitions

Add method to `Component` interface in `metabind-cms/packages/composejs-renderer/types/metabind.d.ts`.

Existing types to reference: `AnimationOption` (line ~353), `AnimationComponent` (line ~297), standard unions like `Alignment`, `EdgeSet`, etc.

After editing, always regenerate Monaco types:
```bash
node metabind-cms/packages/metabind-editor/scripts/generateTypeDefinitions.js
```

## Gotchas

- **Access levels**: Core types like `JSAnimation`, `JSAnimationKind` are `internal`. Properties using them cannot be `public` — use default (internal) access.
- **Directive props come from JS**: The shape of `directive.props` is determined by what the JS modifier handler returns in its `props` object. Always trace both sides.
- **Modifier naming**: The `directiveName` on the Swift side must match the string passed to `#registerBuiltInModifier` on the JS side.
- **GenericModifier default**: If no custom handler is registered for a modifier name, `GenericModifier` is used — it maps positional args to props like `{ arg0: value, arg1: value }`. Many simple modifiers rely on this.
- **Two JS runtimes**: `bindjs-apple/Sources/BindJS/Resources/BindJSRuntime.js` (Swift/native) and `metabind-cms/packages/composejs-runtime/src/runtime/` (React/web). Both need modifier registration. The CMS runtime uses ES module imports with separate files per modifier in `Modifiers/`. The native runtime is a single file. The CMS version does NOT need the JSON-stringify workaround (no AnyDecodable).
- **Component args are functions, not objects**: Built-in components like `Spring(...)`, `Color(...)` return component functions (`f._component = true`), not plain objects. In a custom modifier handler, you must unwrap them: `if (typeof arg === 'function' && arg._component) { const ast = arg(); /* use ast.type, ast.props */ }`. See `withAnimation` in the runtime for the reference pattern.
- **AnyDecodable `type` key collision**: `AnyDecodable` in `Directive.swift` treats any dict with a `type` key as a `Directive`, discarding all other keys. This silently breaks nested dicts like `{ type: "spring", response: 0.5 }` — they become `Directive(type: "spring", props: [:])` and lose the actual data. **Workaround**: JSON-stringify the dict on the JS side (`JSON.stringify(obj)`) and pass it as a string. On the Swift side, decode from the string: `jsonString.data(using: .utf8)` → `JSONDecoder().decode()`.

## Publishing a Binary Release

When changes to bindjs-apple need to ship downstream (to metabind-apple-internal and metabind-app-apple), build an XCFramework and publish it to the `bindjs-apple-binary` repo.

### Steps

1. **Build the XCFramework** from the bindjs-apple repo root:
   ```bash
   bash ./Scripts/build-xcframework.sh
   ```
   This temporarily adds `type: .dynamic` to Package.swift (restored on exit), builds for iOS device + simulator with module stability, creates the XCFramework, zips it, and prints the checksum.

   Output:
   - `.build/xcframework/BindJS.xcframework.zip` — the distributable zip
   - Checksum (SHA256) — printed at the end

2. **Determine the next version** by checking existing tags:
   ```bash
   git -C ../bindjs-apple-binary tag --sort=-version:refname | head -1
   ```

3. **Update Package.swift** in `bindjs-apple-binary` with the new URL and checksum:
   ```swift
   .binaryTarget(
       name: "BindJS",
       url: "https://github.com/yapstudios/bindjs-apple-binary/releases/download/<VERSION>/BindJS.xcframework.zip",
       checksum: "<CHECKSUM>"
   )
   ```
   Commit and push to `develop` (the default branch).

4. **Create the GitHub release** targeting the commit that has the updated Package.swift:
   ```bash
   gh release create <VERSION> .build/xcframework/BindJS.xcframework.zip \
     --title "<VERSION>" --notes "Release notes" \
     --target <COMMIT_SHA> --repo yapstudios/bindjs-apple-binary
   ```
   **Important:** Use `--target` to point at the Package.swift update commit. Creating the release before pushing the Package.swift update will tag the wrong commit, and SPM will resolve the old checksum.

5. **Update downstream** — bump the bindjs-apple-binary dependency version in metabind-apple-internal's Package.swift.

### Key details
- The build script backs up and restores Package.swift automatically
- `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` enables module stability for binary distribution
- SVGViewKit is statically linked into the framework; GLTFKit2 is provided separately by bindjs-apple-binary
- Binary repo default branch is `develop`

## Component Implementation Notes

### Color Handling
- Colors use `ColorComponent` with named colors (e.g., "gray", "primary") or RGBA values
- For simple color fills in shapes, use SwiftUI's `Color` directly with `.fill()` modifier

### Shape Components Pattern
- Shape components typically don't handle fill/stroke internally — use SwiftUI modifiers

### Component Initialization
- Use default values in `init?(from:)` for optional parameters (e.g., `directive["cornerRadius"] ?? 10`)
- Keep components simple — avoid complex state management unless necessary
- Components without parameters still need the full protocol implementation