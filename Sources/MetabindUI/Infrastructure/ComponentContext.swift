import SwiftUI
import JavaScriptCore

public class ComponentContext: ObservableObject {
    private let jsContext: JSContext
    private let runtime: JSValue
    private var actions: [String: (Any?) -> Any?] = [:]
    private var navigateCallback: ((ContentLink) -> Void)?
    private var onOpenURLCallback: ((URL, @escaping (Bool) -> Void) -> Void)?
    private var appState: [String: Any] = [:]
    private var appStateCallback: ((String, Any) -> Void)?

    public init() {
        jsContext = JSContext()!
        jsContext.exceptionHandler = { _, exception in
            if let exception = exception {
                print("JS Error: \(exception)")
            }
        }
        runtime = jsContext.evaluateScript(Self.loadRuntime())
        setupConsoleLog()
        setupNeedsRerender()
        setupWithAnimation()
        setupNavigate()
        setupOnOpenURL()
        setupPerformAction()
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
                return json
                    .invokeMethod("stringify", withArguments: [jsVal])?
                    .toString() ?? "[object]"
            }.joined(separator: " ")
            print(output)
        }

        let console = JSValue(newObjectIn: jsContext)!
        console.setObject(logBlock, forKeyedSubscript: "log" as NSString)
        jsContext.globalObject.setValue(console, forProperty: "console")
    }

    private func setupNeedsRerender() {
        let rerender: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
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
    
    private func setupNavigate() {
        let navigateFunction: @convention(block) (JSValue) -> Void = { [weak self] options in
            guard let self = self else { return }
            
            
            guard let jsonString = jsonStringify(options),
                  let data = jsonString.data(using: .utf8) else {
                print("Invalid options for navigate")
                return
            }
            
            // Decode ContentLink
            do {
                let contentLink = try JSONDecoder().decode(ContentLinkDTO.self, from: data)
                self.navigateCallback?(contentLink.to)
            } catch {
                print("Error decoding ContentLink: \(error)")
            }
        }
        jsContext.setObject(navigateFunction, forKeyedSubscript: "navigateCallback" as NSString)
        _ = jsContext.evaluateScript("runtime.navigateCallback = navigateCallback")
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
            
            if let callback = self.onOpenURLCallback {
                callback(url, swiftResultCallback)
            } else {
                // No callback set - just report failure
                swiftResultCallback(false)
            }
        }
        
        runtime.invokeMethod("setOnOpenURL", withArguments: [onOpenURLFunction])
    }
    
    private func setupPerformAction() {
        let performActionFunction: @convention(block) (String, JSValue?) -> JSValue? = { [weak self] actionName, args in
            guard let self = self else { return nil }
            
            guard let action = self.actions[actionName] else {
                print("Action '\(actionName)' not found")
                return nil
            }
            
            // Convert JSValue args to Swift object if provided
            let swiftArgs: Any?
            if let args = args, !args.isNull && !args.isUndefined {
                swiftArgs = args.toObject()
            } else {
                swiftArgs = nil
            }
            
            // Execute the action
            let result = action(swiftArgs)
            
            // Convert result back to JSValue if it exists
            if let result = result {
                do {
                    let data = try JSONSerialization.data(withJSONObject: result)
                    let jsonString = String(data: data, encoding: .utf8) ?? "null"
                    return self.jsContext.evaluateScript("(\(jsonString))")
                } catch {
                    print("Error serializing action result: \(error)")
                    return nil
                }
            }
            
            return nil
        }
        
        jsContext.setObject(performActionFunction, forKeyedSubscript: "performAction" as NSString)
    }

    public func register(name: String, source: String) {
        runtime.invokeMethod("setComponents", withArguments: [[name: source]])
        objectWillChange.send()
    }

    @ViewBuilder
    public func view(for name: String, arguments: [String: Any] = [:]) -> (some View)? {
        let _ = willRender()
        if let component = componentWithName(name, arguments: arguments) {
            ComponentView(component)
                .environmentObject(self)
                .id(name)
        }
    }
    
    public func componentWithName(_ name: String, arguments: [String: Any] = [:]) -> Component? {
        if let json = runtime
            .invokeMethod("callComponent", withArguments: [[name, JSValue(object: arguments, in: jsContext)!]])
            .toString(),
           let data = json.data(using: .utf8),
           case let decoder = {
               let decoder = JSONDecoder()
               decoder.allowsJSON5 = true
               return decoder
           }(),
           let directive = try? decoder.decode(Directive.self, from: data),
           let component = makeComponent(directive) {
            return component
        }
        return nil
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
    
    public func restorePickerValue(id: String) -> String? {
        runtime.invokeMethod("restorePickerValue", withArguments: [id])?.toString()
    }
    
    public func callPickerSetter(id: String, value: String) {
        _ = runtime.invokeMethod("callEventHandler", withArguments: [id, value])
    }

    public func willRender() {
        runtime.invokeMethod("willRender", withArguments: [])
    }

    public func reset() {
        runtime.invokeMethod("reset", withArguments: [])
        let needsRerenderFunction: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async {
                withAnimation {
                    self?.objectWillChange.send()
                }
            }
        }
        runtime.context.setObject(needsRerenderFunction, forKeyedSubscript: "needsRerender" as NSString)
        runtime.context.evaluateScript("runtime.needsRerender = needsRerender")
    }

    private static func loadRuntime() -> String {
        guard
            let url = Bundle.module.url(forResource: "JSRuntime", withExtension: "js"),
            let jsCode = try? String(contentsOf: url, encoding: .utf8)
        else {
            print("Error loading JSRuntime.js")
            return ""
        }
        return jsCode
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
    
    // MARK: - Action Registry
    
    /// Register an action that takes arguments and returns a codable value
    public func registerAction<R: Codable>(name: String, action: @escaping ([String: Any]) -> R) {
        actions[name] = { args in
            let argumentDict = args as? [String: Any] ?? [:]
            return action(argumentDict)
        }
    }
    
    /// Register an action that takes arguments and returns void
    public func registerAction(name: String, action: @escaping ([String: Any]) -> Void) {
        actions[name] = { args in
            let argumentDict = args as? [String: Any] ?? [:]
            action(argumentDict)
            return nil
        }
    }
    
    // MARK: - Navigation Callback
    
    public func onNavigate(_ callback: @escaping (ContentLink) -> Void) {
        self.navigateCallback = callback
    }
    
    // MARK: - OpenURL Callback
    
    public func onOpenURL(_ callback: @escaping (_ url: URL, _ completion: @escaping (_ success: Bool) -> Void) -> Void) {
        self.onOpenURLCallback = callback
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
            
            // Trigger UI update
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            // Notify Listener
            if let swiftValue {
                self.appStateCallback?(key, swiftValue)
            }
        }
        
        jsContext.setObject(onUpdateAppStateFunction, forKeyedSubscript: "onUpdateAppState" as NSString)
        _ = jsContext.evaluateScript("runtime.onUpdateAppState = onUpdateAppState")
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
