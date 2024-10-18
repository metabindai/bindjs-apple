// MARK: - EmptyComponent

public struct EmptyComponent: ComponentProtocol {
    
    public init() {}
    
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitEmpty(self)
    }
}

// MARK: - Bool

extension Bool: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitBool(self)
    }
}

// MARK: - Int

extension Int: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitInt(self)
    }
}

// MARK: - Double

extension Double: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDouble(self)
    }
}

// MARK: - String

extension String: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitString(self)
    }
}

// MARK: Dictionary

extension [String: ComponentProtocol]: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDictionary(self)
    }
}

// MARK: - Array

extension [ComponentProtocol]: ComponentProtocol {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitArray(self)
    }
}

extension Evaluator {
    
    mutating func visitArray(_ array: [any ComponentProtocol]) -> any ComponentProtocol {
        let mapped = array.map { $0.evaluate(context) }
        switch mapped.count {
        case 0:
            return EmptyComponent()
        case 1:
            return mapped[0]
        default:
            return mapped
        }
    }
    
    mutating func visitDictionary(_ dictionary: [String : any ComponentProtocol]) -> any ComponentProtocol {
        dictionary.mapValues { $0.accept(&self) }
    }
}
