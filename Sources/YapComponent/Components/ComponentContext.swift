import SwiftUI
import JavaScriptCore

public class ComponentContext: ObservableObject {
    private let context: JSContext
    private let runtime: JSValue
    private var actions: [String: (Any?) -> Any?] = [:]

    public init() {
        context = JSContext()!
        context.exceptionHandler = { _, exception in
            if let exception = exception {
                print("JS Error: \(exception)")
            }
        }
        runtime = context.evaluateScript(Self.loadRuntime())
        setupConsoleLog()
        setupNeedsRerender()
        setupWithAnimation()
        setupPerformAction()
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

        let console = JSValue(newObjectIn: context)!
        console.setObject(logBlock, forKeyedSubscript: "log" as NSString)
        context.globalObject.setValue(console, forProperty: "console")
    }

    private func setupNeedsRerender() {
        let rerender: @convention(block) () -> Void = { [weak self] in
            self?.objectWillChange.send()
        }
        context.setObject(rerender, forKeyedSubscript: "needsRerender" as NSString)
        _ = context.evaluateScript("runtime.needsRerender = needsRerender")
    }

    private func setupWithAnimation() {
        let withAnimationFunction: @convention(block) (JSValue, JSValue) -> Void = { [weak self] callback, options in
            guard let self = self else { return }
            let callbackId = callback.toString() ?? ""

            // 1. JSON-stringify the JSValue options dictionary:
            let ctx = JSContext.current() ?? self.context
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
        context.setObject(withAnimationFunction, forKeyedSubscript: "withAnimation" as NSString)
        _ = context.evaluateScript("runtime.withAnimation = withAnimation")
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
                    return self.context.evaluateScript("(\(jsonString))")
                } catch {
                    print("Error serializing action result: \(error)")
                    return nil
                }
            }
            
            return nil
        }
        
        context.setObject(performActionFunction, forKeyedSubscript: "performAction" as NSString)
    }

    public func register(name: String, source: String) {
        runtime.invokeMethod("setComponents", withArguments: [[name: source]])
        objectWillChange.send()
    }

    public func view(for name: String, arguments: [String: Any] = [:]) -> some View {
        willRender()
        if
            let json = runtime
                .invokeMethod("callComponent", withArguments: [[name, JSValue(object: arguments, in: context)!]])
                .toString(),
            let data = json.data(using: .utf8),
            case let decoder = {
                let decoder = JSONDecoder()
                decoder.allowsJSON5 = true
                return decoder
            }(),
            let directive = try? decoder.decode(Directive.self, from: data),
            let component = makeComponent(directive)
        {
            return ComponentView(component)
                .environmentObject(self)
                .id(name)
        }
        return ComponentView(EmptyComponent())
            .environmentObject(self)
            .id(name)
    }

    public func debug() {
        let debugInfo = runtime.invokeMethod("debug", withArguments: [])
        print(debugInfo ?? "No debug info")
    }

    public func environment(_ environment: [String: Any]) -> Self {
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
        let ctx = context ?? self.context
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
}
