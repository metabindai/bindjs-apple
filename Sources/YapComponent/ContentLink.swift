public struct ContentLink: Codable, Hashable, Sendable {
    public let content: String
    public let id: String?
}

struct ContentLinkDTO: Codable, Sendable {
    let to: ContentLink
}
