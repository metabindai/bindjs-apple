import Foundation

struct EqualityVisitor: ComponentVisitor {
    
    let lhs: ComponentProtocol
    
    public mutating func defaultVisit(_ component: any ComponentProtocol) -> Bool {
        return false
    }
    
    mutating func visitBool(_ bool: Bool) -> Bool {
        guard let lhs = lhs as? Bool else { return false }
        return lhs == bool
    }
    
    mutating func visitInt(_ int: Int) -> Bool {
        guard let lhs = lhs as? Int else { return false }
        return lhs == int
    }
    
    mutating func visitDouble(_ double: Double) -> Bool {
        guard let lhs = lhs as? Double else { return false }
        return lhs == double
    }
    
    mutating func visitString(_ string: String) -> Bool {
        guard let lhs = lhs as? String else { return false }
        return lhs == string
    }
    
    mutating func visitArray(_ array: [any ComponentProtocol]) -> Bool {
        guard let lhs = lhs as? [any ComponentProtocol] else { return false }
        guard lhs.count == array.count else { return false }
        return zip(lhs, array).allSatisfy(isEqual)
    }
    
    mutating func visitDictionary(_ dictionary: [String : any ComponentProtocol]) -> Bool {
        guard let lhs = lhs as? [String: any ComponentProtocol] else { return false }
        guard lhs.count == dictionary.count else { return false }
        return dictionary.allSatisfy { key, value in
            isEqual((lhs[key] ?? EmptyComponent()) , value)
        }
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> Bool {
        guard let lhs = lhs as? ConditionalComponent else { return false }
        return isEqual(lhs.condition , conditional.condition)
        && isEqual(lhs.thenContent , conditional.thenContent)
        && isEqual(lhs.elseContent ?? EmptyComponent(), conditional.elseContent ?? EmptyComponent())
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> Bool {
        guard let lhs = lhs as? ForEachComponent else { return false }
        return isEqual(lhs.data , forEach.data)
        && isEqual(lhs.content , forEach.content)
    }
    
    mutating func visitVariable(_ variable: Variable) -> Bool {
        guard let lhs = lhs as? Variable else { return false }
        return lhs.name == variable.name
    }
    
    mutating func visitBinary(_ binary: Binary) -> Bool {
        guard let lhs = lhs as? Binary else { return false }
        return isEqual(lhs.left , binary.left)
        && lhs.operator == binary.operator
        && isEqual(lhs.right , binary.right)
    }
    
    mutating func visitClosure(_ closure: Closure) -> Bool {
        guard let lhs = lhs as? Closure else { return false }
        return isEqual(lhs.props , closure.props)
        && isEqual(lhs.body , closure.body)
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> Bool {
        guard let lhs = lhs as? Defaults else { return false }
        return isEqual(lhs.constants , defaults.constants)
        && isEqual(lhs.content , defaults.content)
    }
    
    mutating func visitComponent(_ component: Component) -> Bool {
        guard let lhs = lhs as? Component else { return false }
        return lhs.type == component.type
        && isEqual(lhs.props , component.props)
        && isEqual(lhs.children , component.children)
    }
    
    public mutating func visitEmpty(_ empty: EmptyComponent) -> Bool {
        guard lhs is EmptyComponent else { return false }
        return true
    }
}

func isEqual (_ lhs: ComponentProtocol, _ rhs: ComponentProtocol) -> Bool {
    var visitor = EqualityVisitor(lhs: lhs)
    return rhs.accept(&visitor)
}
