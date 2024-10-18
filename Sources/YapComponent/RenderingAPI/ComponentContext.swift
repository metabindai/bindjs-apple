import SwiftUI

public class ComponentContext {
    public var parent: ComponentContext?
    
    public init(parent: ComponentContext? = nil) {
        self.parent = parent
    }
    
    public var values: [String: ComponentProtocol] = [:]
    
    public func get(_ name: String) -> ComponentProtocol? {
        values[name] ?? parent?.get(name)
    }
    
    public func define(_ name: String, _ value: ComponentProtocol) {
        values[name] = value
    }
    
    public func define(_ component: Component) {
        values[component.type] = component.evaluate(self)
    }
    
    public func assign(_ name: String, _ value: ComponentProtocol) {
        if values[name] != nil || parent == nil {
            values[name] = value
        } else {
            parent?.assign(name, value)
        }
    }
    
    public var allKeys: Set<String> {
        Set(values.keys).union(parent?.allKeys ?? [])
    }
}

extension ComponentProtocol {
    func evaluate(_ context: ComponentContext) -> ComponentProtocol {
        var evaluator = Evaluator(context: context)
        return accept(&evaluator)
    }
}

struct ComponentContextKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: ComponentContext = .init()
}

extension EnvironmentValues {
    public var componentContext: ComponentContext {
        get {
            self[ComponentContextKey.self]
        }
        set {
            self[ComponentContextKey.self] = newValue
        }
    }
}


// Every actual evaluator implementation is in its respective file.
struct Evaluator: ComponentVisitor {
    let context: ComponentContext
    
    mutating func defaultVisit(_ component: any ComponentProtocol) -> ComponentProtocol {
        component
    }
}


extension ComponentProtocol {
    public var isTruthy: Bool {
        switch self {
        case let bool as Bool:
            return bool
        case is EmptyComponent:
            return false
        default:
            return true
        }
    }
    
    public var arrayValue: [ComponentProtocol] {
        switch self {
        case let array as [ComponentProtocol]:
            return array
        case is EmptyComponent:
            return []
        default:
            return [self]
        }
    }
    
    public var dictionaryValue: [String: ComponentProtocol] {
        switch self {
        case let dictionary as [String: ComponentProtocol]:
            return dictionary
        case is EmptyComponent:
            return [:]
        default:
            return ["self": self]
        }
    }
}
