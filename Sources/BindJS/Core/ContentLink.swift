public enum ContentLink: Codable, Hashable, Sendable {
    case content(String)
    case action(String)
    case destination(String)
    case preview(String)
    
    enum CodingKeys: String, CodingKey {
        case destination
        case content
        case action
        case preview
    }

    public init(from decoder: Decoder) throws {

        //
        // If it's a string, treat as .destination(value)
        //
        if let single = try? decoder.singleValueContainer(),
           let value = try? single.decode(String.self) {
            self = .destination(value)
            return
        }

        //
        // If it's a dictionary, try keys in priority order
        //
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let content = try? container.decode(String.self, forKey: .content) {
            self = .content(content)
            return
        }

        if let action = try? container.decode(String.self, forKey: .action) {
            self = .action(action)
            return
        }

        if let destination = try? container.decode(String.self, forKey: .destination) {
            self = .destination(destination)
            return
        }

        if let preview = try? container.decode(String.self, forKey: .preview) {
            self = .preview(preview)
            return
        }
        
        throw DecodingError.dataCorrupted(
            .init(codingPath: decoder.codingPath,
                  debugDescription: "Invalid ContentLink dictionary")
        )
    }

    public func encode(to encoder: Encoder) throws {
        switch self {

        case .destination(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .destination)

        case .content(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .content)

        case .action(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .action)
        
        case .preview(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .action)
        }
    }
}

struct ContentLinkDTO: Codable, Sendable {
    let to: ContentLink
}
