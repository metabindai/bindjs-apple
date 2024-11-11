import Foundation

// MARK: - Protocols

public protocol ComponentProtocol {
    func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result
}

public protocol ComponentVisitor {
    associatedtype Result
    
    mutating func visit(_ component: ComponentProtocol) -> Result
    mutating func defaultVisit(_ component: ComponentProtocol) -> Result
    mutating func visitEmpty(_ emptyComponent: EmptyComponent) -> Result
    mutating func visitBool(_ bool: Bool) -> Result
    mutating func visitInt(_ int: Int) -> Result
    mutating func visitDouble(_ double: Double) -> Result
    mutating func visitString(_ string: String) -> Result
    mutating func visitArray(_ array: [ComponentProtocol]) -> Result
    mutating func visitDictionary(_ dictionary: [String: ComponentProtocol]) -> Result
    mutating func visitComponent(_ component: Component) -> Result
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> Result
    mutating func visitForEach(_ forEach: ForEachComponent) -> Result
}

extension ComponentVisitor {
    mutating func visit(_ component: ComponentProtocol) -> Result { component.accept(&self) }
    mutating func visitEmpty(_ emptyComponent: EmptyComponent) -> Result { defaultVisit(emptyComponent) }
    mutating func visitBool(_ bool: Bool) -> Result { defaultVisit(bool) }
    mutating func visitInt(_ int: Int) -> Result { defaultVisit(int) }
    mutating func visitDouble(_ double: Double) -> Result { defaultVisit(double) }
    mutating func visitString(_ string: String) -> Result { defaultVisit(string) }
    mutating func visitArray(_ array: [ComponentProtocol]) -> Result { defaultVisit(array) }
    mutating func visitDictionary(_ dictionary: [String: ComponentProtocol]) -> Result { defaultVisit(dictionary) }
    mutating func visitComponent(_ component: Component) -> Result { defaultVisit(component) }
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> Result { defaultVisit(modifiedComponent) }
    mutating func visitForEach(_ forEach: ForEachComponent) -> Result { defaultVisit(forEach) }
}
