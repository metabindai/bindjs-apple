import SwiftUI

public protocol AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result
}

public protocol ASTVisitor {
    associatedtype Result
    mutating func visit(_ node: AST) -> Self.Result
    mutating func defaultVisit(_ node: AST) -> Self.Result
    mutating func visitBool(_ bool: Bool) -> Self.Result
    mutating func visitDouble(_ double: Double) -> Self.Result
    mutating func visitString(_ string: String) -> Self.Result
    mutating func visitEmptyComponent(_ emptyComponent: EmptyComponent) -> Self.Result
    mutating func visitAnyView(_ anyView: AnyView) -> Self.Result
    mutating func visitArray(_ array: [AST]) -> Self.Result
    mutating func visitDictionary(_ dictionary: [String: AST]) -> Self.Result
    mutating func visitComponent(_ component: Component) -> Self.Result
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> Self.Result
    mutating func visitForEach(_ forEach: ForEachComponent) -> Self.Result
}

extension ASTVisitor {
    mutating func visit(_ node: AST) -> Self.Result { node.accept(&self) }
    mutating func visitBool(_ bool: Bool) -> Self.Result { defaultVisit(bool) }
    mutating func visitDouble(_ double: Double) -> Self.Result { defaultVisit(double) }
    mutating func visitString(_ string: String) -> Self.Result { defaultVisit(string) }
    mutating func visitEmptyComponent(_ emptyComponent: EmptyComponent) -> Self.Result { defaultVisit(emptyComponent) }
    mutating func visitAnyView(_ anyView: AnyView) -> Self.Result { defaultVisit(anyView) }
    mutating func visitArray(_ array: [AST]) -> Self.Result { defaultVisit(array) }
    mutating func visitDictionary(_ dictionary: [String: AST]) -> Self.Result { defaultVisit(dictionary) }
    mutating func visitComponent(_ component: Component) -> Self.Result { defaultVisit(component) }
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> Self.Result { defaultVisit(modifiedComponent) }
    mutating func visitForEach(_ forEach: ForEachComponent) -> Self.Result { defaultVisit(forEach) }
}

extension Bool: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitBool(self)
    }
}

extension Double: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDouble(self)
    }
}

extension String: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitString(self)
    }
}

public struct EmptyComponent: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitEmptyComponent(self)
    }
}

extension [AST]: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitArray(self)
    }
}

extension [String: AST]: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDictionary(self)
    }
}

extension AnyView: AST {
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitAnyView(self)
    }
}

public struct Component: AST {
    var type: String
    var props: [String: AST] = [:]
    var children: [AST] {
        get { props["children"] as? [AST] ?? [] }
        set { props["children"] = newValue }
    }
    
    init(type: String, props: [String: AST] = [:], children: [AST] = []) {
        self.type = type
        self.props = props
        if !children.isEmpty {
            self.props["children"] = children
        }
    }
    
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitComponent(self)
    }
    
    func decode<T: AST>(_ key: String) -> T? {
        if let value = props[key] {
            if let decoded = value as? T {
                return decoded
            } else if let lsc = T.self as? any LosslessStringConvertible.Type {
                return lsc.init(String(describing: value)) as? T
            } else if let cc = T.self as? ComponentConvertible.Type, let c = value as? Component {
                return cc.init(c) as? T
            }
        }
        return nil
    }
    
    func decodeAny(_ key: String) -> AST? {
        props[key]
    }
}

public struct ModifiedComponent: AST {
    let content : AST
    let modifier: AST
    
    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitModifiedComponent(self)
    }
}

public struct ForEachComponent: AST {
    let dataId: String
    let count: Int
    let functionId: String
    let environmentId: String

    public func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitForEach(self)
    }
}
