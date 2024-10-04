import SwiftUI
import Combine

public class ComponentContext: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var constants: Set<String> = []
    public var values: [String: Component] = [:]
    public var children: [ComponentContext] = []
    var dependents: [String: Set<WeakBox<ComponentContext>>] = [:]
    var dependencies: [String: WeakBox<ComponentContext>] = [:]
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
        
        objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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
        DependencyTracker.withDependent(self) {
            _get(key)
        }
    }

    
    private func _get(_ key: String) -> Component? {
        if let value = values[key] {
            DependencyTracker.addDependency(self, forKey: key)
            return value
        } else {
            return parent?._get(key)
        }
    }
    
    var allKeys: Set<String> {
        Set(values.keys).union(parent?.allKeys ?? [])
    }
    
    public func assign(_ key: String, _ value: Component) {
        if (values.keys.contains(key) && !constants.contains(key)) || (parent == nil && !constants.contains(key)) {
            let oldValue = values[key] ?? EmptyComponent()
            values[key] = value
            if !YapComponent.isEqual(oldValue, value) {
                notifyDependents(forKey: key)
            }
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
        case print
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
        case .print:
            for (key, value) in arguments {
                print("\(key): \(value.evaluate(self))")
            }
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
extension ComponentContext {
    func addDependency(_ context: ComponentContext, forKey key: String) {
        dependencies[key] = WeakBox(context)
        context.dependents[key, default: []].insert(WeakBox(self))
    }
    
    func notifyDependents(forKey key: String) {
        guard let dependents = dependents[key] else { return }
        for dependent in dependents {
            dependent.value?.valueWillChange(forKey: key)
        }
        self.dependents[key] = dependents.filter { $0.value != nil }
    }
    
    func valueWillChange(forKey key: String) {
        objectWillChange.send()
    }
}

struct DependencyTracker {
    nonisolated(unsafe) static var current: Self?
    let dependent: ComponentContext
    
    static func addDependency(_ context: ComponentContext, forKey key: String) {
        current?.dependent.addDependency(context, forKey: key)
    }
    
    static func withDependent<R>(_ context: ComponentContext, body: () throws -> R) rethrows -> R {
        let old = current
        current = .init(dependent: context)
        defer { current = old }
        return try body()
    }
}


final class WeakBox<T: AnyObject>: Hashable {
    private let identifier: ObjectIdentifier
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
        self.identifier = ObjectIdentifier(value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
