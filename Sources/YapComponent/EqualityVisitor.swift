import Foundation

struct EqualityVisitor: ComponentVisitor {
    
    let lhs: Component
    
    public mutating func defaultVisit(_ component: any Component) -> Bool {
        return false
    }
    
    mutating func visitPrimitive(_ primitive: any PrimitiveComponent) -> Bool {
        switch (lhs, primitive) {
        case (let lhs as Bool, let rhs as Bool): return lhs == rhs
        case (let lhs as Int, let rhs as Int): return lhs == rhs
        case (let lhs as Double, let rhs as Double): return lhs == rhs
        case (let lhs as String, let rhs as String): return lhs == rhs
        default: return false
        }
    }
    
    mutating func visitArray(_ array: [any Component]) -> Bool {
        guard let lhs = lhs as? [any Component] else { return false }
        guard lhs.count == array.count else { return false }
        return zip(lhs, array).allSatisfy(isEqual)
    }
    
    mutating func visitDictionary(_ dictionary: [String : any Component]) -> Bool {
        guard let lhs = lhs as? [String: any Component] else { return false }
        guard lhs.count == dictionary.count else { return false }
        return dictionary.allSatisfy { key, value in
            isEqual((lhs[key] ?? EmptyComponent()) , value)
        }
    }
    
    mutating func visitRange(_ range: RangeExpr) -> Bool {
        guard let lhs = lhs as? RangeExpr else { return false }
        return isEqual(lhs.start , range.start)
        && isEqual(lhs.end , range.end)
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> Bool {
        guard let lhs = lhs as? ConditionalComponent else { return false }
        return isEqual(lhs.condition , conditional.condition)
        && isEqual(lhs.thenContent , conditional.thenContent)
        && isEqual((lhs.elseContent ?? EmptyComponent()), (conditional.elseContent ?? EmptyComponent()))
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
        && lhs.op == binary.op
        && isEqual(lhs.right , binary.right)
    }
    
    mutating func visitClosure(_ closure: Closure) -> Bool {
        guard let lhs = lhs as? Closure else { return false }
        return isEqual(lhs.parameters , closure.parameters)
        && isEqual(lhs.content , closure.content)
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> Bool {
        guard let lhs = lhs as? Defaults else { return false }
        return isEqual(lhs.constants , defaults.constants)
        && isEqual(lhs.content , defaults.content)
    }
    
    mutating func visitState(_ state: StateVars) -> Bool {
        guard let lhs = lhs as? StateVars else { return false }
        return isEqual(lhs.bindings , state.bindings)
    }
    
    mutating func visitDirective(_ directive: Directive) -> Bool {
        guard let lhs = lhs as? Directive else { return false }
        return lhs.type == directive.type
        && isEqual(lhs.props , directive.props)
        && isEqual(lhs.children , directive.children)
    }
    
    public mutating func visitEmpty(_ empty: EmptyComponent) -> Bool {
        guard lhs is EmptyComponent else { return false }
        return true
    }
}

public func isEqual (_ lhs: Component, _ rhs: Component) -> Bool {
    var visitor = EqualityVisitor(lhs: lhs)
    return rhs.accept(&visitor)
}
