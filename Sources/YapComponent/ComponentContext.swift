import SwiftUI

public class ComponentContext: ObservableObject {
    public var parent: ComponentContext?
    public var values: [String: Component] = [:]
    
    public init(parent: ComponentContext? = nil) {
        self.parent = parent
        registerBuiltinsIfNeeded()
    }
    
    public func get(_ key: String) -> Component? {
        values[key] ?? parent?.get(key)
    }
    
    public func assign(_ key: String, _ value: Component) {
        if values.keys.contains(key) || parent == nil {
            values[key] = value
        } else {
            parent?.assign(key, value)
        }
    }
    
    public func define(_ key: String, _ value: Component) {
        if !values.keys.contains(key) {
            values[key] = value
        }
    }
}

// Built-ins.

extension ComponentContext {
    
    private func define(_ key: String, _ body: @escaping (_ props: [String: Component], _ children: [Component]) -> Component) {
        define(key, OpaqueFunction { props, children, callingContext in
            body(props, children).evaluate(callingContext)
        })
    }
    
    func registerBuiltinsIfNeeded() {
        guard parent == nil else { return }
        
        /// Converts the children to a Double if possible.
        define("Double") { props, children in
            (children.map(String.init(describing:)).compactMap { Double($0) as? Component })
        }
        
        define("Int") { props, children in
            (children.map(String.init(describing:)).compactMap { Int($0) as? Component })
        }
        
        define("String") { props, children in
            (children.map(String.init(describing:)).map { $0 as Component })
        }
        
        define("Bool") { props, children in
            (children.map(\.isTruthy))
        }
    }
    
}
