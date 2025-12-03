public struct ContentLink: Codable, Hashable, Sendable {
    public let to: String
    public let props: [String: String]

    public init(to: String, props: [String: String] = [:]) {
        self.to = to
        self.props = props
    }
}
