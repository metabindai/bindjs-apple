# BindJS Component & Modifier Gap Plan

Current inventory: **42 view components**, **~101 modifiers**, **8 animation types**.

Coverage is strong for static layouts, typography, media, shapes, and basic interaction. This plan identifies what's missing for common, polished SwiftUI experiences.

---

## Tier 1 — Fundamental Gaps

Almost every polished app uses these. Their absence limits what content authors can build.

### Components

| Component | Why | Status |
|-----------|-----|--------|
| **TabView + Tab** | Tab-based navigation is table stakes for any multi-section app. Modern syntax uses `Tab("Title", systemImage: "icon") { content }` children instead of `.tabItem()` | Registered in JS runtime, no Swift impl |
| **LazyVGrid / LazyHGrid** | Photo grids, product grids, dashboards — `Grid` exists but lazy grids handle dynamic/large collections | Registered in JS runtime, no Swift impl |
| **Link** | Opening URLs is basic functionality | Registered in JS runtime, no Swift impl |

### Modifiers

| Modifier | Why |
|----------|-----|
| ~~**`.animation(_:value:)`**~~ | ~~The implicit animation modifier~~ — **Done** ([bindjs-apple#55](https://github.com/yapstudios/bindjs-apple/pull/55), [metabind-cms#274](https://github.com/yapstudios/metabind-cms/pull/274)) |
| ~~**`.transition()`**~~ | ~~View enter/exit transitions (`.opacity`, `.slide`, `.move`, `.scale`). Without this, views just pop in/out~~ — **Done** ([bindjs-apple#61](https://github.com/yapstudios/bindjs-apple/pull/61), [metabind-cms#279](https://github.com/yapstudios/metabind-cms/pull/279)). Supports string forms (opacity, slide, scale, identity, blurReplace) and object forms (move, push, scale+anchor, offset, blurReplace config, asymmetric, combined). Also fixed `withAnimation` to flush synchronously inside the animation transaction. |
| **`.alert()`** | Presenting alerts is one of the most common UI patterns. Currently no way to show an alert |
| **`.confirmationDialog()`** | Confirming destructive actions (delete, discard). Standard UX pattern |
| ~~**`.fullScreenCover()`**~~ | ~~Full-screen modal presentation. `.sheet()` exists but full-screen covers are equally common~~ — **Done** ([bindjs-apple#58](https://github.com/yapstudios/bindjs-apple/pull/58), [metabind-cms#276](https://github.com/yapstudios/metabind-cms/pull/276)) |
| ~~**`.listStyle()`**~~ | ~~`.insetGrouped`, `.plain`, `.sidebar` — without this, Lists always look the same~~ — **Done** ([bindjs-apple#60](https://github.com/yapstudios/bindjs-apple/pull/60), [metabind-cms#278](https://github.com/yapstudios/metabind-cms/pull/278)) |
| ~~**`.listRowBackground()`**~~ | ~~Customizing list row appearance~~ — **Done** ([bindjs-apple#60](https://github.com/yapstudios/bindjs-apple/pull/60), [metabind-cms#278](https://github.com/yapstudios/metabind-cms/pull/278)) |
| ~~**`.listRowSeparator()`**~~ | ~~Hiding/showing row separators~~ — **Done** ([bindjs-apple#60](https://github.com/yapstudios/bindjs-apple/pull/60), [metabind-cms#278](https://github.com/yapstudios/metabind-cms/pull/278)) |
| **`.swipeActions()`** | Swipe-to-delete, swipe-to-archive on list rows |
| ~~**`.badge()`**~~ | ~~Notification counts on tabs and list rows~~ — **Done** ([bindjs-apple#56](https://github.com/yapstudios/bindjs-apple/pull/56), [metabind-cms#275](https://github.com/yapstudios/metabind-cms/pull/275)) |
| **`.refreshable()`** | Pull-to-refresh on lists/scroll views |
| **`.searchable()`** | Search bar integration in navigation |

---

## Tier 2 — Polished Experience

Elevates from functional to refined. These are the details that make apps feel native.

### Components

| Component | Why |
|-----------|-----|
| **Form** | Settings screens, input forms — renders with platform-appropriate grouped styling |
| **GroupBox** | Titled container for grouped content |
| **DisclosureGroup** | Expandable/collapsible sections |
| **Slider** | Continuous value input (volume, brightness, price range) |
| **Stepper** | Discrete increment/decrement (quantity selectors) |
| **DatePicker** | Date/time selection |
| ~~**ContentUnavailableView**~~ | ~~Empty states with icon/title/description (iOS 17+)~~ — **Done** ([bindjs-apple#64](https://github.com/yapstudios/bindjs-apple/pull/64), [metabind-cms#284](https://github.com/yapstudios/metabind-cms/pull/284)). Supports title, systemImage, description, custom label override, and action button children. |

### Modifiers

| Modifier | Why |
|----------|-----|
| **`.matchedGeometryEffect()`** | General-purpose hero transitions between views |
| **`.navigationTransition(.zoom)`** | iOS 18+ hero zoom animation for push/pop navigation — the modern alternative to matchedGeometryEffect for navigation contexts |
| ~~**`.contentTransition()`**~~ | ~~Smooth text/number transitions (`.numericText()`, `.interpolate`)~~ — **Done** ([bindjs-apple#67](https://github.com/yapstudios/bindjs-apple/pull/67), [metabind-cms#287](https://github.com/yapstudios/metabind-cms/pull/287)). Supports numericText (with countsDown option), opacity, interpolate, identity. |
| **`.popover()`** | Popover presentation (iPad, Mac) |
| **`.symbolEffect()`** | SF Symbol animations — bounce, pulse, variableColor (iOS 17+) |
| ~~**`.sensoryFeedback()`**~~ | ~~Haptic feedback on interactions (iOS 17+)~~ — **Done** ([bindjs-apple#61](https://github.com/yapstudios/bindjs-apple/pull/61), [metabind-cms#279](https://github.com/yapstudios/metabind-cms/pull/279)). 10 feedback types: impact, selection, success, warning, error, light, medium, heavy, increase, decrease. |
| **`.hoverEffect()`** | Pointer effects on iPadOS/visionOS |
| ~~**`.safeAreaInset()`**~~ | ~~Floating bottom bars, overlaid toolbars~~ — **Done** |
| **`.redacted(reason:)`** | Skeleton/placeholder loading states |
| **`.containerRelativeFrame()`** | Responsive sizing relative to scroll container (iOS 17+) |
| ~~**`.scrollPosition()`**~~ | ~~Programmatic scroll control (iOS 17+)~~ — **Done** ([bindjs-apple#59](https://github.com/yapstudios/bindjs-apple/pull/59), [metabind-cms#277](https://github.com/yapstudios/metabind-cms/pull/277)) |

---

## Tier 3 — Nice to Have

Useful for specific use cases but not blocking common experiences.

### Components

`Gauge`, `ColorPicker`, `Canvas`, ~~`Path`~~ — **Done** ([bindjs-apple#66](https://github.com/yapstudios/bindjs-apple/pull/66), [metabind-cms#286](https://github.com/yapstudios/metabind-cms/pull/286)), ~~`ViewThatFits`~~ — **Done** ([bindjs-apple#68](https://github.com/yapstudios/bindjs-apple/pull/68), [metabind-cms#288](https://github.com/yapstudios/metabind-cms/pull/288)). Supports optional `in` axis constraint and up to 10 alternative children., `TimelineView`, `ShareLink`

### Modifiers

~~`.scrollTargetLayout()`~~, ~~`.scrollTargetBehavior()`~~ ~~(snap scrolling)~~ — **Done** ([bindjs-apple#57](https://github.com/yapstudios/bindjs-apple/pull/57)), `.contentMargins()`, `.geometryGroup()`, `.backgroundStyle()`, `.scrollIndicators()`

---

## Top 5 Bang-for-Buck Groups

Ordered by how much new capability they unlock for content authors.

### 1. TabView + Tab + .badge()

Unlocks the most common app navigation pattern. Nearly every multi-section app is tab-based.

- **TabView** component as the container
- **Tab** component (iOS 18+ syntax) as children: `Tab("Title", systemImage: "icon") { content }`
- ~~**`.badge()`** modifier for notification counts on tabs~~ — **Done**
- Consider `.tabViewStyle()` for page-style swiping
- The modern `Tab {}` syntax replaces the legacy `.tabItem()` modifier

### 2. LazyVGrid / LazyHGrid

Unlocks grid-based layouts: photo galleries, product catalogs, dashboards, icon grids.

- **LazyVGrid** and **LazyHGrid** components
- `GridItem` configuration (fixed, flexible, adaptive sizing)
- Works with existing `ForEach` for data-driven grids

### 3. .alert() + .confirmationDialog()

Unlocks standard user interaction dialogs. Currently there is no way to prompt the user for confirmation or display error messages.

- **`.alert()`** with title, message, and action buttons
- **`.confirmationDialog()`** with title, message, and action buttons (action sheet style)
- Both need `isPresented` binding pattern (same as `.sheet()`)

### 4. ~~.animation() + .transition()~~ — **Done**

- ~~**`.animation(_:value:)`** modifier~~ — **Done**
- ~~**`.transition()`** modifier~~ — **Done**. Full suite: string forms, move/push/scale/offset/blurReplace/asymmetric/combined. Also fixed `withAnimation` transaction flushing so transitions actually animate.

### 5. ~~.fullScreenCover()~~ + .listStyle() + .swipeActions()

Rounds out presentation and list capabilities.

- ~~**`.fullScreenCover()`** — same binding pattern as `.sheet()`, full-screen modal~~ — **Done**
- ~~**`.listStyle()`** — `.plain`, `.insetGrouped`, `.sidebar`, `.grouped`~~ — **Done**
- **`.swipeActions()`** — leading/trailing swipe actions on list rows with Button children

---

## Implementation Notes

### JS Runtime

Many Tier 1 components are already registered in the JS runtime's `componentNames` array (TabView, LazyVGrid, LazyHGrid, Link, Form, etc.). The JS side recognizes these names and creates directives for them, but they fall through to `UnresolvedComponent` on the Swift side. Implementation requires:

1. Swift `Component` conformance (parse directive → SwiftUI view)
2. `ComponentVisitor` protocol extension (add `visit*` method)
3. `componentFactories` registration in `ComponentView.swift`
4. Type definitions in `metabind.d.ts` + regenerate Monaco copy

### Modifier Pattern

New modifiers follow the established pattern:

1. Swift file in `Components/Modifiers/` conforming to `Component` + `ViewModifier`
2. `directiveName` matching the camelCase SwiftUI modifier name
3. `componentFactories` registration
4. `ComponentViewModifier` switch case
5. JS handler in `BindJSRuntime.js` (or rely on `GenericModifier` catch-all)
6. Type definition in `metabind.d.ts`

### Binding-Based Modifiers

`.alert()`, `.confirmationDialog()`, `.fullScreenCover()`, and `.popover()` all use the `isPresented` binding pattern already established by `.sheet()`. The existing `sheet` implementation is the template for all of these.

### Type Definition Sync

After any additions, both type definition files must be updated:
- **Source**: `metabind-cms/packages/composejs-renderer/types/metabind.d.ts`
- **Monaco**: regenerate via `node packages/metabind-editor/scripts/generateTypeDefinitions.js`
