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

## Components Organization
Components should be organized in Sources/MetabindUI/Convertibles with Views/ for basic views and Modifiers/ for modifiers.

## Creating New Components

To add a new component to MetabindUI, follow these steps:

1. **Create the Component File** in `Sources/MetabindUI/Components/Views/` (or `/Modifiers/` for modifiers)
   - Implement the `Component` protocol with `directiveName` and `init?(from:)` 
   - Add `accept<V: ComponentVisitor>` method that calls the appropriate visitor method
   - Make it conform to `View` (or `ViewModifier` for modifiers) with SwiftUI implementation
   - For components with state, use `@State` properties as needed

2. **Add to ComponentVisitor** in `Sources/MetabindUI/Visitors/ComponentVisitor.swift`
   - Add visitor method to the protocol: `mutating func visitYourComponent(_ component: YourComponent) -> Result`
   - Add default implementation in the extension that calls `defaultVisit`

3. **Register in makeComponent** in `Sources/MetabindUI/Components/ComponentView.swift`
   - Add case to the switch statement: `case YourComponent.directiveName: YourComponent(from: directive)`

4. **Add to ComponentView** in `Sources/MetabindUI/Components/ComponentView.swift`
   - Add case to the body switch: `case let yourComponent as YourComponent: yourComponent`
   - For modifiers, add to ComponentViewModifier instead

5. **Register in JS Runtime** in `Sources/MetabindUI/Resources/JSRuntime.js`
   - Add the component name to the `componentNames` array (around line 49)
   - This is REQUIRED for the component to be recognized by the JavaScript runtime
   - Keep the list alphabetically sorted for consistency

6. **Build and Test**
   - Run `swift build` to ensure everything compiles
   - Components should support initialization from directives with various property names

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
- Colors in MetabindUI use the `ColorComponent` type with named colors (e.g., "gray", "primary") or RGBA values
- For simple color fills in shapes, use SwiftUI's `Color` directly with `.fill()` modifier
- Default opacity values can be applied using `.opacity()` modifier

### Shape Components Pattern
- Shape components typically don't need to handle fill/stroke in the component itself
- The shape's appearance can be modified using SwiftUI's built-in modifiers
- RoundedRectangle is commonly used for placeholder-style components with customizable corner radius

### Component Initialization
- Use default values in `init?(from:)` for optional parameters (e.g., `directive["cornerRadius"] ?? 10`)
- Keep components simple - avoid complex state management unless necessary
- Components without parameters still need the full protocol implementation