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

5. **Build and Test**
   - Run `swift build` to ensure everything compiles
   - Components should support initialization from directives with various property names