### Component Rendering Process

1. **JavaScript Runtime and AST Generation:**
   - The `JSComponent` and `ComponentRuntime` classes enable the setup of a JavaScript runtime that generates an AST (Abstract Syntax Tree) by executing JavaScript code.
   - A custom script is injected into `JSContext`, allowing the runtime to handle built-in SwiftUI components and custom logic, register components, manage environments, and cache component data.

2. **AST Parsing and Conversion:**
   - JSON data is decoded into an AST structure. Each JSON object representing a component is mapped to an `AST` type, either a `Component`, `ModifiedComponent`, or a `ComponentConvertible`.
   - The `convertComponent` function checks the component type and attempts to match it to predefined component types (e.g., `Circle`, `Rectangle`, etc.), returning the appropriate `ComponentConvertible` instance.

3. **ComponentView and Rendering:**
   - `ComponentView` takes an `AST` instance and renders the corresponding SwiftUI view based on its type.
   - A `switch` statement handles each possible `AST` case:
     - **Standard Cases** (e.g., `EmptyComponent`, `String`, `AnyView`) are rendered directly.
     - **ComponentConvertible Cases** (e.g., `CircleConvertible`, `ButtonConvertible`) leverage a custom view that applies the necessary SwiftUI modifiers.
     - **Custom View Cases** (e.g., `ModifiedComponent`, `Component`):
       - `ModifiedComponent` uses `ComponentViewModifier` to apply a modifier to the base component.
       - `CustomView` attempts to resolve custom components using the `componentEnvironment`.

4. **Custom Components:**
   - Custom components use the `ComponentView` and look up `component.type` in `componentEnvironment` to either render the view directly or render its children if no specific view is found.

5. **Modifiers and Component Extensions:**
   - Extensions on `ASTVisitor` and `ComponentConvertible` define visiting behaviors for each node type.
   - Adding new components requires:
     - Implementing the new view in the appropriate SwiftUI View or Modifier class.
     - Updating `convertComponent` to recognize the new type.
     - Adding rendering logic in `ComponentView` or `ComponentViewModifier` as needed.
