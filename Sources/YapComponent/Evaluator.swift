struct Evaluator: ComponentVisitor {
    
    let context: ComponentContext
    
    // MARK: - Context Reuse
    
    var indexInContexts: Int = 0
    
    mutating func nextContext() -> ComponentContext {
        defer { indexInContexts += 1 }
        return context.child(at: indexInContexts)
    }
    
    // MARK: - Evaluations
    
    mutating func defaultVisit(_ component: Component) -> Component {
        component
    }
    
    mutating func visitVariable(_ variable: Variable) -> any Component {
        context.get(variable.name) ?? EmptyComponent()
    }
    
    mutating func visitClosure(_ closure: Closure) -> any Component {
        closure.bind(context)
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> any Component {
        let defaultsContext = nextContext()
        
        for (key, value) in defaults.constants {
            defaultsContext.define(key, value.accept(&self), isConstant: true)
        }
        
        return defaults.content.evaluate(defaultsContext)
    }
    
    
    mutating func visitState(_ state: StateVars) -> any Component {
        let stateContext = nextContext()
        
        for (key, value) in state.bindings {
            stateContext.define(key, value.accept(&self), isConstant: false)
        }
        
        return state.content.evaluate(stateContext)
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> any Component {
        if conditional.condition.accept(&self).isTruthy {
            return conditional.thenContent.accept(&self)
        } else if let elseContent = conditional.elseContent {
            return elseContent.accept(&self)
        } else {
            return EmptyComponent()
        }
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> any Component {
        let array = forEach.data.accept(&self).arrayValue
        var result: [Component] = []
        for (index, element) in array.enumerated() {
            let forEachContext = ComponentContext(parent: context)
            forEachContext.define("element", element)
            forEachContext.define("index", index)
            result.append(forEach.content.evaluate(forEachContext))
        }
        return result
    }
    
    mutating func visitBinary(_ binary: Binary) -> any Component {
        switch binary.op {
        case "??": emptyCoalescing(first: binary.left, second: binary.right)
        case "==": isEqual(left: binary.left, right: binary.right)
        case "!=": isNotEqual(left: binary.left, right: binary.right)
        case "+", "-", "*", "/", "%": math(left: binary.left, op: binary.op, right: binary.right)
        case "<", ">", "<=", ">=": comparison(left: binary.left, op: binary.op, right: binary.right)
        case "!" where binary.left is EmptyComponent: negate(right: binary.right)
        case "||": logicalOr(left: binary.left, right: binary.right)
        case "&&": logicalAnd(left: binary.left, right: binary.right)
        case ".": propertyAccess(object: binary.left, key: binary.right)
        default: EmptyComponent()
        }
    }
    
    mutating func visitDirective(_ directive: Directive) -> any Component {
        let evaluatedProps = directive.props.mapValues { $0.accept(&self) }
        
        let directiveContext = nextContext()
//        for (key, value) in evaluatedProps {
//            directiveContext.define(key, value)
//        }
        
        let evaluatedChildren = directive.children.evaluate(directiveContext)
        
        var args = evaluatedProps
        if !(evaluatedChildren is EmptyComponent) {
            args["children"] = evaluatedChildren
        }
        if let result = context.perform(directive.type, with: args) {
            return result
        } else {
            return  Directive(
                type: directive.type,
                props: evaluatedProps,
                children: evaluatedChildren.arrayValue
            )
            .bind(directiveContext)
        }
    }
    
    
    mutating func visitArray(_ array: [any Component]) -> any Component {
        let result = array.compactMap {
            let product = $0.accept(&self)
            return product is EmptyComponent ? nil : product
        }
        switch result.count {
        case 0: return EmptyComponent()
        case 1: return result.first!
        default: return result
        }
    }
    
    mutating func visitDictionary(_ dictionary: [String : any Component]) -> any Component {
        dictionary.mapValues { $0.accept(&self) }
    }
    
    mutating func visitRange(_ range: RangeExpr) -> any Component {
        RangeExpr(start: range.start.accept(&self), end: range.end.accept(&self))
    }
}

extension Evaluator {
    
    private mutating func propertyAccess(object: Component, key: Component) -> Component {
        switch key.accept(&self) {
        case let index as Int: return indexedAccess(object: object, at: index)
        case let string as String:
            if let index = Int(string) { return indexedAccess(object: object, at: index) }
            return object.accept(&self).dictionaryValue[string] ?? EmptyComponent()
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func indexedAccess(object: Component, at index: Int) -> Component {
        let arrayValue = object.accept(&self).arrayValue
        guard arrayValue.indices.contains(index) else {
            return EmptyComponent()
        }
        return arrayValue[index]
    }
    
    private mutating func isEqual(left: Component, right: Component) -> Bool {
        left.accept(&self) == right.accept(&self)
    }
    
    private mutating func isNotEqual(left: Component, right: Component) -> Bool {
        left.accept(&self) != right.accept(&self)
    }
    
    private mutating func negate(right: Component) -> Component {
        let right = right.accept(&self)
        switch right {
        case let bool as Bool: return !bool
        case let int as Int: return -int
        case let double as Double: return -double
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func logicalOr(left: Component, right: Component) -> Bool {
        let left = left.accept(&self)
        if left.isTruthy { return true }
        let right = right.accept(&self)
        return right.isTruthy
    }
    
    private mutating func logicalAnd(left: Component, right: Component) -> Bool {
        let left = left.accept(&self)
        guard left.isTruthy else { return false }
        let right = right.accept(&self)
        return right.isTruthy
    }
    
    mutating func numberOperands(left: Component, right: Component) -> (Component, Component)? {
        switch (left, right) {
        case (let left as Double, let right as Double):
            return (left, right)
        case (let left as Int, let right as Int):
            return (left, right)
        case (let left as Int, _):
            return numberOperands(left: Double(left), right: right)
        case (_, let right as Int):
            return numberOperands(left: left, right: Double(right))
        case (let left as String, let right as String):
            return (left, right)
        default:
            return nil
        }
    }
    
    private mutating func math(left: Component, op: String, right: Component) -> Component {
        let operands = numberOperands(left: left.accept(&self), right: right.accept(&self))
        guard let (left, right) = operands else {
            return EmptyComponent()
        }
        switch (left, right) {
        case (let left as Int, let right as Int):
            switch op {
            case "+": return left &+ right
            case "-": return left &- right
            case "*": return left &* right
            case "/":
                guard right != 0 else { return EmptyComponent() }
                return left / right
            case "%":
                guard right != 0 else { return EmptyComponent() }
                return left % right
            default: return EmptyComponent()
            }
        case (let left as Double, let right as Double):
            switch op {
            case "+": return left + right
            case "-": return left - right
            case "*": return left * right
            case "/":
                guard right != 0 else { return EmptyComponent() }
                return left / right
            case "%":
                guard right != 0 else { return EmptyComponent() }
                return Int(left) % Int(right)
            default: return EmptyComponent()
            }
        case (let left as String, let right as String):
            switch op {
            case "+": return left + right
            default: return EmptyComponent()
            }
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func comparison(left: Component, op: String, right: Component) -> Component {
        let operands = numberOperands(left: left.accept(&self), right: right.accept(&self))
        guard let (left, right) = operands else {
            return EmptyComponent()
        }
        switch (left, right) {
        case (let left as Int, let right as Int):
            if op == "<" { return left < right }
            if op == ">" { return left > right }
            if op == "<=" { return left <= right }
            if op == ">=" { return left >= right }
            return EmptyComponent()
        case (let left as Double, let right as Double):
            if op == "<" { return left < right }
            if op == ">" { return left > right }
            if op == "<=" { return left <= right }
            if op == ">=" { return left >= right }
            return EmptyComponent()
        case (let left as String, let right as String):
            if op == "<" { return left < right }
            if op == ">" { return left > right }
            if op == "<=" { return left <= right }
            if op == ">=" { return left >= right }
            return EmptyComponent()
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func emptyCoalescing(first: Component, second: Component) -> Component {
        if case let first = first.evaluate(context), !(first is EmptyComponent) {
            return first
        } else {
            return second.evaluate(context)
        }
    }
}

extension Component {
    public func evaluate(_ context: ComponentContext) -> Component {
        var evaluator = Evaluator(context: context)
        return accept(&evaluator)
    }
}

extension Component {
    public var isTruthy: Bool {
        switch self {
        case let bool as Bool: return bool
        case is EmptyComponent: return false
        case let array as [Component] where array.isEmpty: return false
        default: return true
        }
    }
    
    public var arrayValue: [Component] {
        switch self {
        case let array as [Component]: return array
        case let range as RangeExpr: return range.arrayValue
        case is EmptyComponent: return []
        default: return [self]
        }
    }
    
    public var dictionaryValue: [String: Component] {
        switch self {
        case let dictionary as [String: Component]: return dictionary
        case is EmptyComponent: return [:]
        default: return ["self": self]
        }
    }
}
