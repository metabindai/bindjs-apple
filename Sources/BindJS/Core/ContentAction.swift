public struct ContentAction: Codable, Hashable, Sendable {
    public let name: String
    public let props: [String: String]?

    public init(name: String, props: [String: String] = [:]) {
        self.name = name
        self.props = props
    }
}
