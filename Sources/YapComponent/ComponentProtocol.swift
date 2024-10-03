// MARK: - Protocols

/// Defines the base Component protocol
public protocol Component {
    func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result
}

/// Defines a primitive component
public protocol PrimitiveComponent: Component {}

// Default implementation for PrimitiveComponent
extension PrimitiveComponent {
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitPrimitive(self)
    }
}

/// Defines the Visitor protocol
public protocol ComponentVisitor {
    associatedtype Result
    
    mutating func visit(_ component: Component) -> Result
    mutating func defaultVisit(_ component: Component) -> Result
    mutating func visitEmpty(_ empty: EmptyComponent) -> Result
    mutating func visitPrimitive(_ primitive: PrimitiveComponent) -> Result
    mutating func visitArray(_ array: [Component]) -> Result
    mutating func visitDictionary(_ dictionary: [String: Component]) -> Result
    mutating func visitConditional(_ conditional: ConditionalComponent) -> Result
    mutating func visitRange(_ range: RangeExpr) -> Result
    mutating func visitForEach(_ forEach: ForEachComponent) -> Result
    mutating func visitVariable(_ variable: Variable) -> Result
    mutating func visitBinary(_ binary: Binary) -> Result
    mutating func visitClosure(_ closure: Closure) -> Result
    mutating func visitDefaults(_ defaults: Defaults) -> Result
    mutating func visitState(_ state: StateVars) -> Result
    mutating func visitDirective(_ directive: Directive) -> Result
}

/// Default Implementation for ComponentVisitor
extension ComponentVisitor {
    public mutating func visit(_ component: Component) -> Result { component.accept(&self) }
    public mutating func visitEmpty(_ empty: EmptyComponent) -> Result { defaultVisit(empty) }
    public mutating func visitPrimitive(_ primitive: PrimitiveComponent) -> Result { defaultVisit(primitive) }
    public mutating func visitArray(_ array: [Component]) -> Result { defaultVisit(array) }
    public mutating func visitDictionary(_ dictionary: [String: Component]) -> Result { defaultVisit(dictionary) }
    public mutating func visitConditional(_ conditional: ConditionalComponent) -> Result { defaultVisit(conditional) }
    public mutating func visitRange(_ range: RangeExpr) -> Result { defaultVisit(range) }
    public mutating func visitForEach(_ forEach: ForEachComponent) -> Result { defaultVisit(forEach) }
    public mutating func visitVariable(_ variable: Variable) -> Result { defaultVisit(variable) }
    public mutating func visitBinary(_ binary: Binary) -> Result { defaultVisit(binary) }
    public mutating func visitClosure(_ closure: Closure) -> Result { defaultVisit(closure) }
    public mutating func visitDefaults(_ defaults: Defaults) -> Result { defaultVisit(defaults) }
    public mutating func visitDirective(_ directive: Directive) -> Result { defaultVisit(directive) }
}

// MARK: - Component Implementations

/// A type-erasing wrapper for Component
public struct AnyComponent: Component, CustomStringConvertible {
    public var component: Component
    
    public init(_ component: Component) {
        if let anyComponent = component as? AnyComponent {
            self = anyComponent
        } else {
            self.component = component
        }
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        component.accept(&visitor)
    }
    
    public var description: String {
        String(describing: component)
    }
}

extension Component {
    public var erasedToAnyComponent: AnyComponent { AnyComponent(self) }
    
    public var unerased: Component {
        if let anyComponent = self as? AnyComponent {
            return anyComponent.component
        }
        return self
    }
}

/// Represents an empty component
public struct EmptyComponent: Component {
    public init() {}
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitEmpty(self)
    }
}

// MARK: - Extensions for primitive types

extension Bool: PrimitiveComponent {}
extension Int: PrimitiveComponent {}
extension Double: PrimitiveComponent {}
extension String: PrimitiveComponent {}

// MARK: - Extensions for collection types

extension [Component]: Component {
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitArray(self)
    }
}

extension [String: Component]: Component {
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitDictionary(self)
    }
}

// MARK: - Complex Component Types

/// Represents a conditional component
public struct ConditionalComponent: Component {
    var condition: Component
    var thenContent: Component
    var elseContent: Component?
    
    public init(condition: Component, then thenContent: Component, else elseContent: Component? = nil) {
        self.condition = condition
        self.thenContent = thenContent
        self.elseContent = elseContent
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitConditional(self)
    }
}

public struct RangeExpr: Component {
    let start: Component
    let end: Component
    
    public init(start: Component, end: Component) {
        self.start = start
        self.end = end
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitRange(self)
    }
    
    var arrayValue: [Component] {
        var evaluator = Evaluator(context: .init())
        guard let (lhs, rhs) = evaluator.numberOperands(left: self.start, right: self.end) else {
            return []
        }
        switch (lhs, rhs) {
        case (let lhs as Int, let rhs as Int):
            return (lhs..<rhs).map { $0 as Component }
        case (let lhs as Double, let rhs as Double):
            return (Int(lhs)..<Int(rhs)).map { $0 as Component }
        default: return []
        }
    }
}

/// Represents a forEach component
public struct ForEachComponent: Component {
    var data: Component
    var content: Component
    
    public init(data: Component, content: Component) {
        self.data = data
        self.content = content
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitForEach(self)
    }
}

/// Represents a variable
public struct Variable: PrimitiveComponent {
    var name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitVariable(self)
    }
}

public func Children() -> Variable {
    Variable(name: "children")
}

public func Index() -> Variable {
    Variable(name: "index")
}

public func Element() -> Variable {
    Variable(name: "element")
}

/// Represents a binary operation
public struct Binary: Component {
    var left: Component
    var op: String
    var right: Component
    
    public init(left: Component, op: String, right: Component) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitBinary(self)
    }
}

extension Component {
    public func or(_ other: Component) -> Component {
        Binary(left: self, op: "||", right: other)
    }
    
    public func and(_ other: Component) -> Component {
        Binary(left: self, op: "&&", right: other)
    }
    
    public func negated() -> Component {
        Binary(left: EmptyComponent(), op: "!", right: self)
    }
    
    public func replacingEmpty(with defaultValue: Component) -> Component {
        Binary(left: EmptyComponent(), op: "??", right: self)
    }
    
    public func adding(_ other: Component) -> Component {
        Binary(left: self, op: "+", right: other)
    }
    
    /// Same thing as `Component.adding(_:)`.
    public func concat(_ other: Component) -> Component {
        Binary(left: self, op: "+", right: other)
    }
    
    public func subtracting(_ other: Component) -> Component {
        Binary(left: self, op: "-", right: other)
    }
    
    public func multiplied(by other: Component) -> Component {
        Binary(left: self, op: "*", right: other)
    }
    
    public func divided(by other: Component) -> Component {
        Binary(left: self, op: "/", right: other)
    }
    
    public func modulo(_ other: Component) -> Component {
        Binary(left: self, op: "%", right: other)
    }
    
    public func isEqual(to other: Component) -> Component {
        Binary(left: self, op: "==", right: other)
    }
    
    public func isNotEqual(to other: Component) -> Component {
        Binary(left: self, op: "!=", right: other)
    }
    
    public func isLessThan(_ other: Component) -> Component {
        Binary(left: self, op: "<", right: other)
    }
    
    public func isGreaterThan(_ other: Component) -> Component {
        Binary(left: self, op: ">", right: other)
    }
    
    public func isLessThanOrEqual(to other: Component) -> Component {
        Binary(left: self, op: "<=", right: other)
    }
    
    public func isGreaterThanOrEqual(to other: Component) -> Component {
        Binary(left: self, op: ">=", right: other)
    }
    
    public func get(_ key: String) -> Component {
        Binary(left: self, op: ".", right: key)
    }
    
    public func get(_ index: Int) -> Component {
        Binary(left: self, op: ".", right: index)
    }
}

public protocol Callable: Component {
    func callAsFunction(_ arguments: [String: Component], _ callingContext: ComponentContext) -> Component
}

/// Represents a closure
public struct Closure: Callable {
    public var parameters: [String: Component]
    public var content: Component
    public var enclosedContext: ComponentContext?
    
    public init(parameters: [String: Component], content: Component) {
        self.parameters = parameters
        self.content = content
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitClosure(self)
    }
    
    public func bind(_ context: ComponentContext) -> Closure {
        var closure = self
        closure.enclosedContext = context
        return closure
    }
    
    public func callAsFunction(_ arguments: [String: Component] = [:], _ callingContext: ComponentContext) -> any Component {
        let context = ComponentContext()
        for (key, value) in parameters {
            context.define(key, value)
        }
        for (key, value) in arguments {
            context.assign(key, value)
        }
        context.parent = enclosedContext
        return content.evaluate(context)
    }
}

/// Represents default values
public struct Defaults: Component {
    public let constants: [String: Component]
    public var content: Component
    
    public init(constants: [String: Component], content: Component) {
        self.constants = constants
        self.content = content
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitDefaults(self)
    }
}

extension Component {
    public func defaults(_ key: String, _ value: Component) -> some Component {
        Defaults(constants: [key: value], content: self)
    }
}

public struct StateVars: Component {
    public var bindings: [String: Component]
    public var content: Component
    
    public init(bindings: [String: Component], content: Component) {
        self.bindings = bindings
        self.content = content
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitState(self)
    }
}

public extension Component {
    func state(_ bindings: [String: Component]) -> StateVars {
        StateVars(bindings: bindings, content: self)
    }
    
    func state(_ key: String, _ value: Component) -> some Component {
        StateVars(bindings: [key: value], content: self)
    }
}

/// Represents a directive
public struct Directive: Component {
    public var type: String
    public var props: [String: Component]
    public var children: [Component]
    public var enclosedContext: ComponentContext?
    
    public init(type: String, props: [String: Component] = [:], children: [Component] = []) {
        self.type = type
        self.props = props
        self.children = children
    }
    
    public func accept<Visitor: ComponentVisitor>(_ visitor: inout Visitor) -> Visitor.Result {
        visitor.visitDirective(self)
    }
    
    func bind(_ context: ComponentContext) -> Directive {
        var directive = self
        directive.enclosedContext = context
        return directive
    }
}

extension Directive {
    public init(_ type: String, _ _0: Component) {
        if let props = _0 as? [String: Component] {
            self.init(type: type, props: props)
        } else {
            self.init(type: type, props: ["_0": _0])
        }
    }
}

extension Component {
    public func modifier(_ type: String, _ _0: Component) -> Directive {
        if let props = _0 as? [String: Component] {
            Directive(type: type, props: props, children: [self])
        } else {
            Directive(type: type, props: ["_0": _0], children: [self])
        }
    }
    
    public func modifier(_ type: String) -> Directive {
        Directive(type: type, children: [self])
    }
}
