# BindJS Rendering Performance

This document covers the performance optimizations applied to the BindJS SwiftUI rendering engine, measured with Instruments traces using the Animation Hitches + SwiftUI template.

## Baseline

The unoptimized engine produced **32 hitches** (3 severe >100ms, worst 187.5ms) during a typical content interaction session. The root cause was a cascade of compounding issues:

1. Each JS state change fired `objectWillChange.send()` immediately — multiple state changes in a single handler caused multiple full SwiftUI render passes
2. Each render rebuilt the entire component tree from JavaScript
3. Container views used `ForEach(children.indices, id: \.self)` — SwiftUI couldn't diff, so it tore down and rebuilt every child on every update
4. `ForEachComponent.body` called into JavaScriptCore synchronously during SwiftUI's render pass
5. These compounded: a single content update triggered millions of `AttributeInvalidatingSubscriber.invalidateAttribute()` calls

## Optimizations

### 1. Coalesced rerender signals

**File:** `BindJSContext.swift` — `setupNeedsRerender()`, `setupAppStateListener()`

**Problem:** JS code like `setCount(1); setName("foo")` fired `objectWillChange.send()` twice, causing two full SwiftUI render passes per interaction.

**Fix:** Added a `rerenderScheduled` flag. The first `needsRerender` call sets the flag and schedules a single `DispatchQueue.main.async` block. Subsequent calls within the same JS execution are no-ops. The same coalescing gate is shared with `onUpdateAppState`.

```swift
let rerender: @convention(block) () -> Void = { [weak self] in
    guard let self, !self.rerenderScheduled else { return }
    self.rerenderScheduled = true
    DispatchQueue.main.async {
        self.rerenderScheduled = false
        self.objectWillChange.send()
    }
}
```

**Impact:** Reduces render passes per interaction from N (one per state setter) to 1.

### 2. Pre-computed ForEach children

**Files:** `BindJSContext.swift` — `resolveForEachChildren(in:)`, `evaluateForEachChildren(_:)`;  `ForEach.swift`

**Problem:** `ForEachComponent.body` called `context.callForEachFunction()` per item, invoking JavaScriptCore synchronously during SwiftUI's render pass. For 30 items, that's 30 JS evaluations blocking the main thread.

**Fix:** After `componentForName` builds the component tree from JS, `resolveForEachChildren` walks the tree and evaluates all ForEach children before returning to SwiftUI. The ForEach body renders pre-computed children with no JS calls.

```swift
// BindJSContext.swift — uses ComponentRewriter to walk the tree
private struct ForEachResolver: ComponentRewriter {
    unowned let context: BindJSContext

    mutating func visitForEach(_ forEach: ForEachComponent) -> Component {
        var copy = forEach
        copy.resolvedChildren = context.evaluateForEachChildren(forEach)
            .map { $0.accept(visitor: &self) }
        return copy
    }
}

private func resolveForEachChildren(in component: Component) -> Component {
    var resolver = ForEachResolver(context: self)
    return resolver.visit(component)
}

// ForEach.swift — no JS during render
public var body: some View {
    ForEach(identifiedChildren(resolvedChildren ?? [])) { child in
        ComponentView(child.component)
    }
}
```

**Impact:** Moved ForEach JS evaluation out of SwiftUI body evaluation into the pre-render phase. JSC lexer/parser/bytecode-generator frames no longer appear in ForEach-related hitch time profiles. Note: `GeometryReaderComponent` and `NavigationLinkContentView` still call JS during body as their callbacks depend on runtime geometry/navigation state.

### 3. Removed root contentTransition

**File:** `BindJSContext.swift` — `viewForName`, `viewForPreview`

**Problem:** Both rendering entry points applied `.contentTransition(.numericText())` and `.environment(\.contentTransitionAddsDrawingGroup, true)` to the entire component tree. This forced Metal drawingGroup rasterization (offscreen render passes) on every frame, even though numeric text transitions were only relevant to a tiny subset of views.

**Fix:** Removed both modifiers entirely. Content transitions should be applied at the component level where needed, not globally.

**Impact:** Eliminated offscreen render passes. `AttributeInvalidatingSubscriber` count dropped from 49K to 19K.

### 4. Direct modifier application

**File:** `ModifiedComponent.swift`

**Problem:** `ModifiedComponent` is the most frequently instantiated component (every modifier wraps content in one). Its body used `ForEach` over `content`, adding ForEach overhead to every single modifier in the tree.

**Fix:** Since ModifiedComponent always has exactly one content child, the body now applies the modifier directly without ForEach, with a guard for the empty case.

```swift
// Before
ForEach(children.indices, id: \.self) { index in
    ComponentView(children[index])
        .modifier(ComponentViewModifier(modifier))
}

// After
if let first = content.first {
    ComponentView(first)
        .modifier(ComponentViewModifier(modifier))
}
```

**Impact:** Eliminated ForEach identity tracking overhead for the most common component type. ComponentView.body evaluations dropped from ~30K to ~3.6K.

## Results

| Metric | Before | After | Change |
|--------|-------:|------:|--------|
| Total hitches | 32 | 43 | +34% (more mild hitches detected, fewer severe) |
| Severe hitches (>100ms) | 3 | 1 | -67% |
| Warning hitches (>33ms) | 5 | 4 | -20% |
| Worst hitch | 187.5ms | 112.5ms | -40% |
| AttributeInvalidatingSubscriber | ~millions | 19,639 | ~99% reduction |
| ComponentView.body evals | ~30,000 | 3,613 | -88% |
| Total SwiftUI causes | ~800,000 | 692,936 | -13% |

## Approaches that didn't work

### @Observable migration

Migrated `BindJSContext` from `ObservableObject` to `@Observable` with a tracked `renderVersion` property. Since `renderVersion` is read at the root (`viewForName`/`viewForPreview`), observation triggers at the root level, invalidating the entire tree on every update — equivalent to `ObservableObject`. Total causes increased from ~693K to ~800K. Reverted.

**Lesson:** `@Observable` only helps when individual views read individual properties. A single root-level tracked property negates the benefit.

### Background JS initialization

Moved `BindJSContext` creation, runtime evaluation, and component registration to a background thread. Gated rendering on an `isReady` flag.

Any approach that introduces a conditional (`if isReady`) or two-phase lifecycle (empty then populated) in the SwiftUI body creates `_ConditionalContent` wrappers. These generate "Conditional View Value" events on every rerender and force full tree rebuilds when the branch switches. Total causes increased from ~693K to ~1.4M across two iterations. Reverted.

**Lesson:** SwiftUI needs stable view identity from the first frame. Two-phase rendering (show nothing, then show content) is fundamentally incompatible with efficient SwiftUI diffing.
