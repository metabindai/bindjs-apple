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