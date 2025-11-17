//
//  MetabindView.swift
//  Athena
//

import SwiftUI
import Combine
import BindJS

// MARK: - Pure Rendering View (No Networking)

/// Pure rendering view - accepts compiled content data only
/// Works like SwiftUI's Image - you provide the data, it renders
public struct BindJSView: View {
    let content: ResolvedContent

    public init(content: ResolvedContent) {
        self.content = content
    }

    public var body: some View {
        ContextHostView(content: content)
    }
}

// MARK: - Environment Values

extension EnvironmentValues {
    @Entry var onNavigation: ((ContentLink) -> Void)?
    @Entry var appStateBinding: Binding<[String: Any]>?
    @Entry var componentEnvironment: [String: Any] = [:]
}

// MARK: - Metabind Context for Configuration

public struct MetabindContext {
    public var onNavigation: ((ContentLink) -> Void)?
    public var appState: Binding<[String: Any]>?
    var environment: [String: Any] = [:]

    mutating public func environment(_ key: String, value: Any) {
        environment[key] = value
    }
}

public extension View {
    func metabind(_ transform: (_ context: inout MetabindContext) -> Void) -> some View {
        var context = MetabindContext()
        transform(&context)
        return self
            .transformEnvironment(\.componentEnvironment) { env in
                env.merge(context.environment, uniquingKeysWith: { _, new in new })
            }
            .environment(\.onNavigation, context.onNavigation)
            .environment(\.appStateBinding, context.appState)
    }
}

private extension View {
    @ViewBuilder
    func conditional(_ condition: Bool, @ViewBuilder content: (_ view: Self) -> some View) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

// MARK: - Context Host (Rendering Engine)

private struct ContextHostView: View {
    let content: ResolvedContent

    @StateObject private var context: ComponentContext
    @State private var registeredContentHash: Int

    @Environment(\.onNavigation) private var onNavigation
    @Environment(\.appStateBinding) private var appStateBinding
    @Environment(\.self) private var environment
    @Environment(\.componentEnvironment) private var componentEnvironment
    @Environment(\.openURL) private var openURL

    init(content: ResolvedContent) {
        self.content = content

        // Create and register context
        let ctx = ComponentContext()

        // Register package components
        for (name, source) in content.package.components {
            ctx.register(name: name, source: source)
        }

        // Register main content body (entry point for rendering)
        ctx.register(name: "_body", source: content.compiled)

        _context = StateObject(wrappedValue: ctx)

        // Track initial content hash
        _registeredContentHash = State(initialValue: content.hashValue)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                RenderEffect {
                    setupNavigation()
                    setupAppState()
                    setupHooks()
                    setupEnvironment(geometry: geometry)
                }
                context.viewForName("_body")
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onChange(of: content) { _, newContent in
            withAnimation(.snappy) {
                reregisterIfNeeded(newContent)
            }
        }
    }

    private func reregisterIfNeeded(_ newContent: ResolvedContent) {
        let newHash = newContent.hashValue

        // Only re-register if content changed
        guard registeredContentHash != newHash else { return }
        registeredContentHash = newHash

        // Re-register package components
        for (name, source) in newContent.package.components {
            context.register(name: name, source: source)
        }

        // Re-register main content body (entry point for rendering)
        context.register(name: "_body", source: newContent.compiled)
    }

    private func setupNavigation() {
        context.onNavigate { link in
            onNavigation?(link)
        }
    }

    private func setupHooks() {
        context.onOpenURL(openURL.callAsFunction(_:completion:))
    }

    private func setupAppState() {
        guard let appStateBinding else { return }

        context.onAppStateChanged { _, _ in
            // prevent mid-render mutations during the initial set
        }
        _ = context.setAppState(appStateBinding.wrappedValue)
        context.onAppStateChanged { key, value in
            var d = appStateBinding.wrappedValue
            d[key] = value
            appStateBinding.wrappedValue = d
        }
    }

    private func setupEnvironment(geometry: GeometryProxy) {
        let builder = EnvironmentBuilder(
            geometry: geometry,
            environment: environment,
            componentEnvironment: componentEnvironment
        )
        _ = context.setEnvironment(builder.build())
    }
}

private struct RenderEffect: View {
    init(perform: () -> Void) {
        perform()
    }

    var body: some View {
        EmptyView()
    }
}

// MARK: - Environment Builder

private struct EnvironmentBuilder {
    let geometry: GeometryProxy
    let environment: EnvironmentValues
    let componentEnvironment: [String: Any]

    func build() -> [String: Any] {
        var result: [String: Any] = [:]

        // Geometry & Screen
        result["geometry"] = buildGeometry()
        result["screen"] = buildScreen()

        // Locale & Time
        result["locale"] = environment.locale.identifier
        result["timeZone"] = environment.timeZone.identifier
        result["calendar"] = environment.calendar.identifier
        result["now"] = ISO8601DateFormatter().string(from: Date())

        // Visual & Theme
        result["colorScheme"] = environment.colorScheme == .dark ? "dark" : "light"
        result["layoutDirection"] = environment.layoutDirection == .rightToLeft ? "rightToLeft" : "leftToRight"
        result["displayScale"] = environment.displayScale
        result["pixelLength"] = environment.pixelLength

        // Size Classes & Type
        result["horizontalSizeClass"] = Self.sizeClassString(environment.horizontalSizeClass)
        result["verticalSizeClass"] = Self.sizeClassString(environment.verticalSizeClass)
        result["dynamicTypeSize"] = Self.dynamicTypeSizeString(environment.dynamicTypeSize)
        result["contentSizeCategory"] = Self.sizeCategoryString(environment.sizeCategory)

        // State & Phase
        result["isEnabled"] = environment.isEnabled
        result["redactionReasons"] = Self.redactionReasonsStringArray(environment.redactionReasons)
        result["scenePhase"] = Self.scenePhaseString(environment.scenePhase)

        // Accessibility
        result["accessibility"] = buildAccessibility()

        // Platform-specific
        #if os(iOS) || os(tvOS)
        result["colorSchemeContrast"] = Self.colorSchemeContrastString(environment.colorSchemeContrast)
        #endif

        // Merge custom environment overrides
        for (key, value) in componentEnvironment {
            result[key] = value
        }

        return result
    }

    private func buildGeometry() -> [String: Any] {
        [
            "size": [
                "width": geometry.size.width,
                "height": geometry.size.height,
            ],
            "safeAreaInsets": [
                "top": geometry.safeAreaInsets.top,
                "bottom": geometry.safeAreaInsets.bottom,
                "leading": geometry.safeAreaInsets.leading,
                "trailing": geometry.safeAreaInsets.trailing
            ]
        ]
    }

    private func buildScreen() -> [String: Any] {
        [
            "width": geometry.size.width,
            "height": geometry.size.height,
            "safeAreaInsets": [
                "top": geometry.safeAreaInsets.top,
                "bottom": geometry.safeAreaInsets.bottom,
                "leading": geometry.safeAreaInsets.leading,
                "trailing": geometry.safeAreaInsets.trailing
            ]
        ]
    }

    private func buildAccessibility() -> [String: Any] {
        [
            "differentiateWithoutColor": environment.accessibilityDifferentiateWithoutColor,
            "reduceMotion": environment.accessibilityReduceMotion,
            "reduceTransparency": environment.accessibilityReduceTransparency,
            "invertColors": environment.accessibilityInvertColors,
            "showButtonShapes": environment.accessibilityShowButtonShapes,
            "voiceOverEnabled": environment.accessibilityVoiceOverEnabled,
            "switchControlEnabled": environment.accessibilitySwitchControlEnabled,
        ]
    }

    // MARK: - Conversion Helpers

    static func sizeClassString(_ sizeClass: UserInterfaceSizeClass?) -> String {
        switch sizeClass {
        case .compact: return "compact"
        case .regular: return "regular"
        case .none: return "none"
        @unknown default: return "unknown"
        }
    }

    static func redactionReasonsStringArray(_ reasons: RedactionReasons) -> [String] {
        var result: [String] = []
        if reasons.contains(.placeholder) { result.append("placeholder") }
        if reasons.contains(.privacy) { result.append("privacy") }
        return result
    }

    static func dynamicTypeSizeString(_ dynamicTypeSize: DynamicTypeSize) -> String {
        switch dynamicTypeSize {
        case .xSmall: return "xSmall"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        case .xLarge: return "xLarge"
        case .xxLarge: return "xxLarge"
        case .xxxLarge: return "xxxLarge"
        case .accessibility1: return "accessibility1"
        case .accessibility2: return "accessibility2"
        case .accessibility3: return "accessibility3"
        case .accessibility4: return "accessibility4"
        case .accessibility5: return "accessibility5"
        @unknown default: return "unknown"
        }
    }

    static func sizeCategoryString(_ c: ContentSizeCategory) -> String {
        switch c {
        case .extraSmall: return "extraSmall"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        case .extraLarge: return "extraLarge"
        case .extraExtraLarge: return "extraExtraLarge"
        case .extraExtraExtraLarge: return "extraExtraExtraLarge"
        case .accessibilityMedium: return "accessibilityMedium"
        case .accessibilityLarge: return "accessibilityLarge"
        case .accessibilityExtraLarge: return "accessibilityExtraLarge"
        case .accessibilityExtraExtraLarge: return "accessibilityExtraExtraExtraLarge"
        case .accessibilityExtraExtraExtraLarge: return "accessibilityExtraExtraExtraLarge"
        default: return "unspecified"
        }
    }

    static func scenePhaseString(_ p: ScenePhase) -> String {
        switch p {
        case .active: return "active"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
    }

    #if os(iOS) || os(tvOS)
    static func colorSchemeContrastString(_ c: ColorSchemeContrast) -> String {
        switch c {
        case .standard: return "standard"
        case .increased: return "increased"
        @unknown default: return "unknown"
        }
    }
    #endif
}
