public protocol ComponentConvertible: ComponentProtocol {
    init(_ component: Component)
    var component: Component { get }
}

extension ComponentConvertible {
    public func accept<V: ComponentVisitor>(_ visitor: inout V) -> V.Result {
        visitor.visitComponent(component)
    }
}
