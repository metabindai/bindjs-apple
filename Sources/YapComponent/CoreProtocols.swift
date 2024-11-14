import SwiftUI

protocol AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result
}

protocol ASTVisitor {
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
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitBool(self)
    }
}

extension Double: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDouble(self)
    }
}

extension String: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitString(self)
    }
}

struct EmptyComponent: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitEmptyComponent(self)
    }
}

extension [AST]: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitArray(self)
    }
}

extension [String: AST]: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitDictionary(self)
    }
}

extension AnyView: AST {
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitAnyView(self)
    }
}

struct Component: AST {
    var type: String
    var props: [String: AST] = [:]
    var children: [AST] {
        get { props["children"] as? [AST] ?? [] }
        set { props["children"] = newValue }
    }
    
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
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
}

struct ModifiedComponent: AST {
    let content : AST
    let modifier: AST
    
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitModifiedComponent(self)
    }
}

struct ForEachComponent: AST {
    let dataId: String
    let count: Int
    let functionId: String
    
    func accept<V: ASTVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitForEach(self)
    }
}
