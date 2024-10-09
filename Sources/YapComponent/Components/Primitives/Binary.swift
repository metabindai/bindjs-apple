import SwiftUI

public struct Binary: ComponentProtocol {
    let left: ComponentProtocol
    let `operator`: String
    let right: ComponentProtocol
    
    public func accept<V>(_ visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitBinary(self)
    }
}

struct BinaryView: View {
    
    @Environment(\.componentContext) private var context
    let binary: Binary
    
    init(_ binary: Binary) {
        self.binary = binary
    }
    
    var body: some View {
        ComponentView(binary.evaluate(context))
    }
    
}

extension Evaluator {
    mutating func visitBinary(_ binary: Binary) -> any ComponentProtocol {
        switch binary.operator {
        case "??": emptyCoalescing(first: binary.left, second: binary.right)
        case "==": evaluateIsEqual(left: binary.left, right: binary.right)
        case "!=": isNotEqual(left: binary.left, right: binary.right)
        case "+", "-", "*", "/", "%": math(left: binary.left, op: binary.operator, right: binary.right)
        case "<", ">", "<=", ">=": comparison(left: binary.left, op: binary.operator, right: binary.right)
        case "!" where binary.left is EmptyComponent: negate(right: binary.right)
        case "||": logicalOr(left: binary.left, right: binary.right)
        case "&&": logicalAnd(left: binary.left, right: binary.right)
        case ".": propertyAccess(object: binary.left, key: binary.right)
        default: EmptyComponent()
        }
    }
}

extension Evaluator {
    
    private mutating func propertyAccess(object: ComponentProtocol, key: ComponentProtocol) -> ComponentProtocol {
        switch key.accept(&self) {
        case let index as Int: return indexedAccess(object: object, at: index)
        case let string as String:
            if let index = Int(string) { return indexedAccess(object: object, at: index) }
            return object.accept(&self).dictionaryValue[string] ?? EmptyComponent()
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func indexedAccess(object: ComponentProtocol, at index: Int) -> ComponentProtocol {
        let arrayValue = object.accept(&self).arrayValue
        guard arrayValue.indices.contains(index) else {
            return EmptyComponent()
        }
        return arrayValue[index]
    }
    
    private mutating func evaluateIsEqual(left: ComponentProtocol, right: ComponentProtocol) -> Bool {
        isEqual(left.accept(&self), right.accept(&self))
    }
    
    private mutating func isNotEqual(left: ComponentProtocol, right: ComponentProtocol) -> Bool {
        !isEqual(left.accept(&self), right.accept(&self))
    }
    
    private mutating func negate(right: ComponentProtocol) -> ComponentProtocol {
        let right = right.accept(&self)
        switch right {
        case let bool as Bool: return !bool
        case let int as Int: return -int
        case let double as Double: return -double
        default:
            return EmptyComponent()
        }
    }
    
    private mutating func logicalOr(left: ComponentProtocol, right: ComponentProtocol) -> Bool {
        let left = left.accept(&self)
        if left.isTruthy { return true }
        let right = right.accept(&self)
        return right.isTruthy
    }
    
    private mutating func logicalAnd(left: ComponentProtocol, right: ComponentProtocol) -> Bool {
        let left = left.accept(&self)
        guard left.isTruthy else { return false }
        let right = right.accept(&self)
        return right.isTruthy
    }
    
    mutating func numberOperands(left: ComponentProtocol, right: ComponentProtocol) -> (ComponentProtocol, ComponentProtocol)? {
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
    
    private mutating func math(left: ComponentProtocol, op: String, right: ComponentProtocol) -> ComponentProtocol {
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
    
    private mutating func comparison(left: ComponentProtocol, op: String, right: ComponentProtocol) -> ComponentProtocol {
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
    
    private mutating func emptyCoalescing(first: ComponentProtocol, second: ComponentProtocol) -> ComponentProtocol {
        if case let first = first.evaluate(context), !(first is EmptyComponent) {
            return first
        } else {
            return second.evaluate(context)
        }
    }
}


extension ComponentProtocol {
    public func or(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "||", right: other)
    }
    
    public func and(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "&&", right: other)
    }
    
    public func negated() -> ComponentProtocol {
        Binary(left: EmptyComponent(), operator: "!", right: self)
    }
    
    public func replacingEmpty(with defaultValue: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "??", right: defaultValue)
    }
    
    public func adding(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "+", right: other)
    }
    
    /// Same thing as `ComponentProtocol.adding(_:)`.
    public func concat(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "+", right: other)
    }
    
    public func subtracting(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "-", right: other)
    }
    
    public func multiplied(by other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "*", right: other)
    }
    
    public func divided(by other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "/", right: other)
    }
    
    public func modulo(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "%", right: other)
    }
    
    public func isEqual(to other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "==", right: other)
    }
    
    public func isNotEqual(to other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "!=", right: other)
    }
    
    public func isLessThan(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "<", right: other)
    }
    
    public func isGreaterThan(_ other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: ">", right: other)
    }
    
    public func isLessThanOrEqual(to other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: "<=", right: other)
    }
    
    public func isGreaterThanOrEqual(to other: ComponentProtocol) -> ComponentProtocol {
        Binary(left: self, operator: ">=", right: other)
    }
    
    public func child(_ key: String) -> ComponentProtocol {
        Binary(left: self, operator: ".", right: key)
    }
    
    public func child(_ index: Int) -> ComponentProtocol {
        Binary(left: self, operator: ".", right: index)
    }
}
