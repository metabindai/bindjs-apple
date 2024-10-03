import SwiftUI
import Combine

public class ComponentContext: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var constants: Set<String> = []
    public var values: [String: Component] = [:]
    public var children: [ComponentContext] = []
    public weak var parent: ComponentContext? = nil {
        didSet {
            if oldValue !== parent {
                objectWillChange.send()
            }
            setupPublishers()
        }
    }

    public init(parent: ComponentContext? = nil) {
        self.parent = parent
        registerBuiltinsIfNeeded()
        setupPublishers()
    }
    
    func setupPublishers() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        objectWillChange.sink { [weak self] _ in
            self?.parent?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public func child(at index: Int) -> ComponentContext {
        guard children.indices.contains(index) else {
            let context = ComponentContext(parent: self)
            children.append(context)
            return context
        }
        return children[index]
    }
    
    public func get(_ key: String) -> Component? {
        values[key] ?? parent?.get(key)
    }
    
    var allKeys: Set<String> {
        Set(values.keys).union(parent?.allKeys ?? [])
    }
    
    public func assign(_ key: String, _ value: Component) {
        if (values.keys.contains(key) && !constants.contains(key)) || (parent == nil && !constants.contains(key)) {
            values[key] = value
            objectWillChange.send()
        } else {
            parent?.assign(key, value)
        }
    }
    
    public func define(_ key: String, _ value: Component, isConstant: Bool = true) {
        if !values.keys.contains(key) {
            values[key] = value
            if isConstant {
                constants.insert(key)
            }
        }
    }
    
    enum BuiltinActionName: String {
        case setValueForKey
    }
    
    // Handle the directive or delegate to the user defined values
    public func perform(_ name: String, with arguments: [String: Component]) -> Component? {
        switch BuiltinActionName(rawValue: name) {
        case .setValueForKey:
            guard let key = arguments["key"] as? String, let value = arguments["value"] else {
                // Delegate to user defined below
                fallthrough
            }
            assign(key, value)
            return EmptyComponent()
            
        default:
            if let callable = get(name) as? Callable {
                let result = callable.callAsFunction(arguments, self)
                return result
            }
            return nil
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
