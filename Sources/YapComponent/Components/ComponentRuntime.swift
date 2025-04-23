import SwiftUI
import JavaScriptCore

public class ComponentRuntime: ObservableObject {
    private let context: JSContext
    private let runtime: JSValue
    
    public init() {
        self.context = JSContext()!
        
        context.exceptionHandler = { context, exception in
            if let exception = exception {
                print("JS Error: \(exception)")
            }
        }
        
        // Swift print bridge
        let printFunction: @convention(block) (String) -> Void = { message in print(message) }
        let console = ["log": printFunction]
        context.setObject(console, forKeyedSubscript: "console" as NSString)
        
        // Evaluate the main JS script (provided as 'script')
        self.runtime = context.evaluateScript(Self.loadRuntime())
        
        // Bridge needsRerender → objectWillChange (on main queue)
        let rerender: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async { withAnimation { self?.objectWillChange.send() } }
        }
        context.setObject(rerender, forKeyedSubscript: "needsRerender" as NSString)
        _ = context.evaluateScript("runtime.needsRerender = needsRerender")
    }
    
    public func register(name: String, source: String) {
        runtime.invokeMethod("setComponents", withArguments: [[name: source]])
        objectWillChange.send()
    }
    
    public func makeView(_ name: String, arguments: [String: Any] = [:]) -> some View {
        willRender()
        if
            let json = runtime.invokeMethod("callComponent", withArguments: [[name, JSValue(object: arguments, in: context)!]]).toString(),
            let data = json.data(using: .utf8),
            let directive = try? JSONDecoder().decode(Directive.self, from: data),
            let component = makeComponent(directive)
        {
            return ComponentView(component)
                .environmentObject(self)
        }
        return ComponentView(EmptyComponent())
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
        if let result = runtime.invokeMethod("restoreFunction", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func restoreEnvironment(id: String) {
        runtime.invokeMethod("restoreEnvironment", withArguments: [id])
    }
    
    public func callForEachFunction(id: String, element: JSValue, index: Int32) -> JSValue? {
        setForEachElementId(id: "\(index)")
        
        if let result = runtime.invokeMethod("callForEachFunction", withArguments: [id, element, index]) {
            return result
        }
        return nil
    }
    
    public func setForEachElementId(id: String) -> Void {
        runtime.invokeMethod("setForEachElementId", withArguments: [id])
    }
    
    public func restoreEventHandler(id: String) -> JSValue? {
        if let result = runtime.invokeMethod("restoreEventHandler", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func callEventHandler(id: String, arguments: [Any]) -> JSValue? {
        if let result = runtime.invokeMethod("callEventHandler", withArguments: [id, arguments]) {
            return result
        }
        return nil
    }
    
    public func restoreForEachData(id: String) -> JSValue? {
        if let result = runtime.invokeMethod("restoreForEachData", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func willRender() {
        runtime.invokeMethod("willRender", withArguments: [])
    }
    
    public func reset() {
        runtime.invokeMethod("reset", withArguments: [])
        
        
        // After runtime is created, bridge the needsRerender function
        let needsRerenderFunction: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async {
                withAnimation {
                    self?.objectWillChange.send()
                }
            }
        }
        
        runtime.context.setObject(needsRerenderFunction, forKeyedSubscript: "needsRerender" as NSString)
                        
        // Set up the needsRerender function
        runtime.context.evaluateScript("runtime.needsRerender = needsRerender")
    }
    
    /// Loads the file JSRuntime.js in the project
    private static func loadRuntime() -> String {
        guard let url = Bundle.module.url(forResource: "JSRuntime", withExtension: "js") else {
            return ""
        }
        
        do {
            let jsCode = try String(contentsOf: url, encoding: .utf8)
            return jsCode
        } catch {
            print("Error loading JS file: \(error)")
            return ""
        }
    }
}
