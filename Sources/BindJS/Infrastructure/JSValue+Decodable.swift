import Foundation
import JavaScriptCore

extension JSValue {
    /// Decodes a Decodable type directly from this JSValue without stringify/parse overhead
    func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        // Convert JSValue to Swift dictionary/array
        guard let object = self.toObject() else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "JSValue could not be converted to Swift object"
                )
            )
        }

        // Serialize to Data (fast, no string conversion)
        let data = try JSONSerialization.data(withJSONObject: object, options: [])

        // Decode using standard JSONDecoder
        return try decoder.decode(type, from: data)
    }

    /// Convenience method for when decoding might fail
    func tryDecode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
        try? decode(type, decoder: decoder)
    }
}
