import Foundation

public func decode(from json: String) -> AST {
    let data = json.data(using: .utf8)!
    do {
        let any = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed, .json5Allowed])
        return decode(any)
    } catch {
        return decode(json)
    }
}

public func decode(_ any: Any) -> AST {
    switch any {
    case is NSNull:
        return EmptyComponent()
    case let number as NSNumber:
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            // Check if the NSNumber represents a Bool
            return number.boolValue
        } else {
            // Otherwise, treat it as Double
            return number.doubleValue
        }
    case let string as String:
        return string
    case let array as [Any]:
        return array.map(decode)
    case let dictionary as [String: Any]:
        if let type = dictionary["type"] as? String {
            switch type {
            case "ForEach":
                let dataId = dictionary["dataId"] as? String ?? ""
                let count = dictionary["count"] as? Int ?? 0
                let functionId = dictionary["functionId"] as? String ?? ""
                return ForEachComponent(dataId: dataId, count: count, functionId: functionId)
            case "ModifiedComponent":
                let content = decode(dictionary["content"] ?? [:])
                let modifier = decode(dictionary["modifier"] ?? [:])
                return ModifiedComponent(content: content, modifier: modifier)
            default:
                let props = (dictionary["props"] as? [String: Any] ?? [:]).mapValues(decode)
                let component = Component(type: type, props: props)
                return convertComponent(component) ?? component
            }
        } else {
            return dictionary.mapValues(decode)
        }
    default:
        return EmptyComponent()
    }
}
