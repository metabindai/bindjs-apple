protocol Callable: ComponentProtocol {
    var enclosedContext: ComponentContext? { get }
    func callAsFunction(_ arguments: [String: ComponentProtocol], context: ComponentContext) -> ComponentProtocol
}
