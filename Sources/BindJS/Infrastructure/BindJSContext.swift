import SwiftUI
import JavaScriptCore

public struct BindJSPreviewInfo: Sendable, Equatable {
    public let id: String
    public let title: String
}

public class BindJSContext: ObservableObject {
    private let jsContext: JSContext
    private let runtime: JSValue
    private var actionCallback: ((ContentAction) -> Void)?

    private var openURL: OpenURLAction?
    private var appState: [String: Any] = [:]
    private var appStateCallback: ((String, Any) -> Void)?
    private var jsTimers: JSTimers
    private var rerenderScheduled = false

    public init() {
        jsContext = JSContext()!
        jsContext.exceptionHandler = { _, exception in
            if let exception = exception {
                print("JS Error: \(exception)")
            }
        }
        jsTimers = JSTimers()
        jsTimers.install(in: jsContext)
        runtime = jsContext.evaluateScript(Self.loadRuntime())
        setupConsoleLog()
        setupNeedsRerender()
        setupWithAnimation()
        setupAction()
        setupOnOpenURL()
        setupAppStateListener()
    }

    private func setupConsoleLog() {
        let logBlock: @convention(block) () -> Void = {
            guard
                let args = JSContext.currentArguments(),
                let ctx = JSContext.current(),
                let json = ctx.objectForKeyedSubscript("JSON")
            else { return }

            let output = args.map { raw -> String in
                guard let jsVal = raw as? JSValue else {
                    return String(describing: raw)
                }
                if jsVal.isNull        { return "null" }
                if jsVal.isUndefined   { return "undefined" }
                if jsVal.isString      { return jsVal.toString() ?? "" }
                if jsVal.isBoolean     { return jsVal.toBool() ? "true" : "false" }
                if jsVal.isNumber      { return String(jsVal.toDouble()) }

                // Check if it's an Error object (has message and/or stack properties)
                if let message = jsVal.forProperty("message"), !message.isUndefined {
                    let stack = jsVal.forProperty("stack")?.toString() ?? ""
                    let errorMessage = message.toString() ?? "Unknown error"
                    if !stack.isEmpty {
                        return "\(errorMessage)\n\(stack)"
                    }
                    return errorMessage
                }

                return json
                    .invokeMethod("stringify", withArguments: [jsVal])?
                    .toString() ?? "[object]"
            }.joined(separator: " ")
            print(output)
        }

        let console = JSValue(newObjectIn: jsContext)!
        console.setObject(logBlock, forKeyedSubscript: "log" as NSString)
        console.setObject(logBlock, forKeyedSubscript: "error" as NSString)
        console.setObject(logBlock, forKeyedSubscript: "warn" as NSString)
        jsContext.globalObject.setValue(console, forProperty: "console")
    }

    private func setupNeedsRerender() {
        let rerender: @convention(block) () -> Void = { [weak self] in
            guard let self, !self.rerenderScheduled else { return }
            self.rerenderScheduled = true
            DispatchQueue.main.async {
                self.rerenderScheduled = false
                self.objectWillChange.send()
            }
        }
        jsContext.setObject(rerender, forKeyedSubscript: "needsRerender" as NSString)
        _ = jsContext.evaluateScript("runtime.needsRerender = needsRerender")
    }

    private func setupWithAnimation() {
        let withAnimationFunction: @convention(block) (JSValue, JSValue) -> Void = { [weak self] callback, options in
            guard let self = self else { return }
            let callbackId = callback.toString() ?? ""

            // 1. JSON-stringify the JSValue options dictionary:
            guard let jsonString = jsonStringify(options),
                  let data = jsonString.data(using: .utf8) else {
                // Fallback: No or invalid options; just animate with default
                withAnimation(.smooth) {
                    _ = self.callEventHandler(id: callbackId, arguments: [])
                }
                return
            }

            // 2. Decode and apply JSAnimation
            if let jsAnimation = try? JSONDecoder().decode(JSAnimation.self, from: data) {
                jsAnimation.apply {
                    _ = self.callEventHandler(id: callbackId, arguments: [])
                }
            } else {
                // Could not decode, fallback to default
                withAnimation(.smooth) {
                    _ = self.callEventHandler(id: callbackId, arguments: [])
                }
            }
        }
        jsContext.setObject(withAnimationFunction, forKeyedSubscript: "withAnimation" as NSString)
        _ = jsContext.evaluateScript("runtime.withAnimation = withAnimation")
    }
    
    private func setupAction() {
        let actionFunction: @convention(block) (JSValue) -> Void = { [weak self] options in
            guard let self = self else { return }
            
            guard let jsonString = jsonStringify(options),
                  let data = jsonString.data(using: .utf8) else {
                print("Invalid options for action")
                return
            }
            
            // Decode ContentLink
            do {
                let contentAction = try JSONDecoder().decode(ContentAction.self, from: data)
                self.actionCallback?(contentAction)
            } catch {
                print("Error decoding ContentAction: \(error)")
            }
        }
        jsContext.setObject(actionFunction, forKeyedSubscript: "actionCallback" as NSString)
        _ = jsContext.evaluateScript("runtime.actionCallback = actionCallback")
    }
    
    private func setupOnOpenURL() {
        let onOpenURLFunction: @convention(block) (String, JSValue?) -> Void = { [weak self] urlString, resultCallback in
            guard let self = self else { return }

            let swiftResultCallback: (Bool) -> Void = { success in
                if let resultCallback = resultCallback, !resultCallback.isNull && !resultCallback.isUndefined {
                    _ = resultCallback.call(withArguments: [success])
                }
            }

            guard let url = URL(string: urlString) else {
                // Invalid URL - report failure
                swiftResultCallback(false)
                return
            }

            if let openURL = self.openURL {
                openURL(url, completion: swiftResultCallback)
            } else {
                // No openURL set - just report failure
                swiftResultCallback(false)
            }
        }

        runtime.invokeMethod("setOnOpenURL", withArguments: [onOpenURLFunction])
    }

    public func register(name: String, source: String) {
        runtime.invokeMethod("setComponents", withArguments: [[name: source]])
        objectWillChange()
    }

    @ViewBuilder
    public func viewForName(_ name: String, arguments: [String: Any] = [:]) -> (some View)? {

        let _ = runtime.invokeMethod("willRender", withArguments: [])

        if let component = componentForName(name, arguments: arguments) {
            ComponentView(component)
                .environmentObject(self)
                .id(name)
        }
    }

    public func componentForName(_ name: String, arguments: [String: Any] = [:]) -> Component? {
        guard let jsValue = runtime.invokeMethod("callComponent", withArguments: [[name, JSValue(object: arguments, in: jsContext)!]]) else {
            return nil
        }

        guard let directive = jsValue.toDirective() else {
            return nil
        }

        guard let component = makeComponent(directive) else {
            return nil
        }

        return resolveForEachChildren(in: component)
    }

    // MARK: - Component Previews

    public func previewsForComponent(_ name: String) -> [BindJSPreviewInfo] {
        guard let jsValue = runtime.invokeMethod("getComponentPreviewsWithMetadata", withArguments: [[name]]) else {
            return []
        }
        guard jsValue.isArray, let array = jsValue.toArray() else {
            return []
        }
        return array.enumerated().compactMap { index, item in
            guard let dict = item as? [String: Any] else { return nil }
            let title = dict["title"] as? String ?? "Preview \(index + 1)"
            return BindJSPreviewInfo(id: "\(index)", title: title)
        }
    }

    @ViewBuilder
    public func viewForPreview(_ name: String, previewIndex: Int, arguments: [String: Any] = [:]) -> (some View)? {
        let _ = runtime.invokeMethod("willRender", withArguments: [])

        if let component = componentForPreview(name, previewIndex: previewIndex, arguments: arguments) {
            ComponentView(component)
                .environmentObject(self)
                .id("\(name)_preview_\(previewIndex)")
        }
    }

    public func componentForPreview(_ name: String, previewIndex: Int, arguments: [String: Any] = [:]) -> Component? {
        guard let jsValue = runtime.invokeMethod("callComponentPreview", withArguments: [[name, previewIndex, JSValue(object: arguments, in: jsContext)!]]) else {
            return nil
        }

        guard let directive = jsValue.toDirective() else {
            return nil
        }

        guard let component = makeComponent(directive) else {
            return nil
        }

        return resolveForEachChildren(in: component)
    }

    // MARK: - ForEach Pre-computation

    private struct ForEachResolver: ComponentRewriter {
        weak let context: BindJSContext?

        mutating func visitForEach(_ forEach: ForEachComponent) -> Component {
            var copy = forEach
            copy.resolvedChildren = context?.evaluateForEachChildren(forEach)
                .map { $0.accept(visitor: &self) }
            return copy
        }
    }

    private func resolveForEachChildren(in component: Component) -> Component {
        var resolver = ForEachResolver(context: self)
        return resolver.visit(component)
    }

    private func evaluateForEachChildren(_ forEach: ForEachComponent) -> [Component] {
        guard let data = restoreForEachData(id: forEach.dataId) else { return [] }
        restoreEnvironment(id: forEach.environmentId)

        var components: [Component] = []
        for index in 0..<forEach.count {
            guard let item = data.atIndex(index),
                  let jsValue = callForEachFunction(id: forEach.functionId, element: item, index: Int32(index)),
                  let directive = jsValue.toDirective(),
                  let component = makeComponent(directive) else { continue }
            components.append(component)
        }
        return components
    }

    private func objectWillChange() {
        objectWillChange.send()
    }

    public func debug() {
        let debugInfo = runtime.invokeMethod("debug", withArguments: [])
        print(debugInfo ?? "No debug info")
    }

    public func setEnvironment(_ environment: [String: Any]) -> Self {
        runtime.invokeMethod("setEnvironment", withArguments: [environment])
        return self
    }

    public func restoreFunction(id: String) -> JSValue? {
        runtime.invokeMethod("restoreFunction", withArguments: [id])
    }

    public func restoreEnvironment(id: String) {
        runtime.invokeMethod("restoreEnvironment", withArguments: [id])
    }

    public func callForEachFunction(id: String, element: JSValue, index: Int32) -> JSValue? {
        setForEachElementId(id: "\(index)")
        return runtime.invokeMethod("callForEachFunction", withArguments: [id, element, index])
    }

    public func setForEachElementId(id: String) {
        runtime.invokeMethod("setForEachElementId", withArguments: [id])
    }

    public func restoreEventHandler(id: String) -> JSValue? {
        runtime.invokeMethod("restoreEventHandler", withArguments: [id])
    }

    public func callEventHandler(id: String, arguments: Any) -> JSValue? {
        runtime.invokeMethod("callEventHandler", withArguments: [id, arguments])
    }

    public func restoreForEachData(id: String) -> JSValue? {
        runtime.invokeMethod("restoreForEachData", withArguments: [id])
    }

    public func restoreOnChangeTrigger(id: String) -> Int {
        Int(runtime.invokeMethod("restoreOnChangeTrigger", withArguments: [id])?.toInt32() ?? 0)
    }

    public func triggerOnChangeHandler(id: String) {
        _ = runtime.invokeMethod("triggerOnChangeHandler", withArguments: [id])
    }

    public func restorePickerValue(id: String) -> String? {
        runtime.invokeMethod("restorePickerValue", withArguments: [id])?.toString()
    }

    public func callPickerSetter(id: String, value: String) {
        _ = runtime.invokeMethod("callEventHandler", withArguments: [id, value])
    }

    public func restoreTextFieldValue(id: String) -> String? {
        runtime.invokeMethod("restoreTextFieldValue", withArguments: [id])?.toString()
    }

    public func callTextFieldSetter(id: String, value: String) {
        _ = runtime.invokeMethod("callEventHandler", withArguments: [id, value])
    }

    public func restoreSecureFieldValue(id: String) -> String? {
        runtime.invokeMethod("restoreSecureFieldValue", withArguments: [id])?.toString()
    }

    public func callSecureFieldSetter(id: String, value: String) {
        _ = runtime.invokeMethod("callEventHandler", withArguments: [id, value])
    }

    public func restoreToggleValue(id: String) -> Bool? {
        runtime.invokeMethod("restoreToggleValue", withArguments: [id])?.toBool()
    }

    public func callToggleSetter(id: String, value: Bool) {
        _ = runtime.invokeMethod("callEventHandler", withArguments: [id, value])
    }

    public func reset() {
        runtime.invokeMethod("reset", withArguments: [])
        setupNeedsRerender()
        setupWithAnimation()
        setupAction()
        setupOnOpenURL()
        setupAppStateListener()
    }

    private static func loadRuntime() -> String {
        guard
            let coreUrl = Bundle.module.url(forResource: "BindJSRuntime", withExtension: "js"),
            let wrapperUrl = Bundle.module.url(forResource: "BindJSRuntimeWrapper", withExtension: "js"),
            let coreCode = try? String(contentsOf: coreUrl, encoding: .utf8),
            let wrapperCode = try? String(contentsOf: wrapperUrl, encoding: .utf8)
        else {
            print("Error loading JSRuntime files")
            return ""
        }
        return coreCode + "\n" + wrapperCode
    }
    
    /// JSON-encodes a JSValue using the JavaScript JSON.stringify function.
    /// - Parameters:
    ///   - value: The JSValue (dictionary/object/array/anything) to stringify.
    ///   - context: Context to use (defaults to self.context).
    /// - Returns: JSON string if successful, otherwise nil.
    private func jsonStringify(_ value: JSValue?, in context: JSContext? = nil) -> String? {
        let ctx = context ?? self.jsContext
        guard let value = value else { return nil }
        guard let json = ctx.objectForKeyedSubscript("JSON") else { return nil }
        return json.invokeMethod("stringify", withArguments: [value])?.toString()
    }
    
    // MARK: - Action Callback
    
    public func onAction(_ callback: @escaping (ContentAction) -> Void) {
        self.actionCallback = callback
    }
    
    // MARK: - OpenURL

    public func setOpenURL(_ openURL: OpenURLAction) {
        self.openURL = openURL
    }
    
    // MARK: - App State Management
    
    private func setupAppStateListener() {
        let onUpdateAppStateFunction: @convention(block) (String, JSValue, JSValue) -> Void = { [weak self] key, value, state in
            guard let self = self else { return }
            
            // Convert JSValue to Swift objects
            let swiftValue = value.toObject()
            let swiftState = state.toObject() as? [String: Any] ?? [:]
            
            // Update internal app state
            self.appState = swiftState
            
            // Trigger UI update (coalesced with needsRerender)
            if !self.rerenderScheduled {
                self.rerenderScheduled = true
                DispatchQueue.main.async {
                    self.rerenderScheduled = false
                    self.objectWillChange.send()
                }
            }
            
            // Notify Listener
            if let swiftValue {
                self.appStateCallback?(key, swiftValue)
            }
        }
        
        jsContext.setObject(onUpdateAppStateFunction, forKeyedSubscript: "onUpdateAppState" as NSString)
        _ = jsContext.evaluateScript("runtime.onUpdateAppState = onUpdateAppState")
    }
    
    public func updateAppState(key: String, value: Any) {
        // Update runtime app state
        runtime.invokeMethod("updatedAppState", withArguments: [key, value, nil])
    }

    public func setAppState(_ state: [String: Any]) -> Self {
        runtime.invokeMethod("setAppState", withArguments: [state])
        return self
    }
    
    public func onAppStateChanged(
        _ callback: @escaping (String, Any) -> Void
    ) {
        self.appStateCallback = callback
    }
}
