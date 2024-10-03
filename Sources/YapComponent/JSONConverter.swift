import Foundation

private struct JSONConverter: ComponentVisitor {
    mutating func visitEmpty(_ empty: EmptyComponent) -> Any {
        NSNull()
    }
    
    mutating func visitPrimitive(_ primitive: any PrimitiveComponent) -> Any {
        primitive
    }
    
    mutating func visitArray(_ array: [any Component]) -> Any {
        array.map { $0.accept(&self) }
    }
    
    mutating func visitDictionary(_ dictionary: [String : any Component]) -> Any {
        dictionary.mapValues { $0.accept(&self) }
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> Any {
        [
            "type": "Conditional",
            "condition": conditional.condition.accept(&self),
            "then": conditional.thenContent.accept(&self),
            "else": conditional.elseContent?.accept(&self) ?? NSNull()
        ]
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> Any {
        [
            "type": "ForEach",
            "data": forEach.data.accept(&self),
            "content": forEach.content.accept(&self)
        ]
    }
    
    mutating func visitVariable(_ variable: Variable) -> Any {
        [
            "type": "Variable",
            "name": variable.name
        ]
    }
    
    mutating func visitBinary(_ binary: Binary) -> Any {
        [
            "type": "Binary",
            "left": binary.left.accept(&self),
            "operator": binary.op,
            "right": binary.right.accept(&self)
        ]
    }
    
    mutating func visitClosure(_ closure: Closure) -> Any {
        [
            "type": "Closure",
            "content": closure.content.accept(&self)
        ]
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> Any {
        [
            "type": "Defaults",
            "constants": defaults.constants.mapValues { $0.accept(&self) },
            "content": defaults.content.accept(&self)
        ]
    }
    
    mutating func visitDirective(_ directive: Directive) -> Any {
        var result: [String: Any] = [
            "type": directive.type,
        ]
        if !directive.props.isEmpty {
            result["props"] = directive.props.mapValues { $0.accept(&self) }
        }
        if !directive.children.isEmpty {
            result["children"] = directive.children.accept(&self)
        }
        return result
    }
    
    mutating func visitRange(_ range: RangeExpr) -> Any {
        [
            "type": "Range",
            "start": range.start.accept(&self),
            "end": range.end.accept(&self)
        ]
    }
    
    mutating func defaultVisit(_ component: any Component) -> Any {
        fatalError()
    }
}

extension NSNumber {
    var isBool: Bool {
        CFBooleanGetTypeID() == CFGetTypeID(self)
    }
    
    var isInt: Bool {
        CFNumberGetType(self) == .sInt64Type
    }
}

func makeComponent(_ any: Any) -> Component {
    switch any {
    case is NSNull: return EmptyComponent()
    case let number as NSNumber:
        if number.isBool { return number.boolValue }
        if number.isInt { return number.intValue }
        return number.doubleValue
    case let string as String: return string
    case let array as [Any]: return array.map(makeComponent)
    case let dict as [String: Any]:
        if let type = dict["type"] as? String {
            switch type {
                case "Conditional":
                    return ConditionalComponent(
                        condition: makeComponent(dict["condition"]!),
                        then: makeComponent(dict["then"]!),
                        else: makeComponent(dict["else"]!)
                    )
                case "ForEach":
                    return ForEachComponent(
                        data: makeComponent(dict["data"]!),
                        content: makeComponent(dict["content"]!)
                    )
                case "Variable":
                    return Variable(name: dict["name"] as! String)
                case "Binary":
                    return Binary(
                        left: makeComponent(dict["left"]!),
                        op: dict["operator"] as! String,
                        right: makeComponent(dict["right"]!)
                    )
                case "Closure":
                    return Closure(
                        parameters: (dict["parameters"] as? [String: Any] ?? [:]).mapValues(makeComponent),
                        content: makeComponent(dict["content"]!)
                    )
                case "Defaults":
                    return Defaults(
                        constants: (dict["constants"] as? [String: Any] ?? [:]).mapValues(makeComponent),
                        content: makeComponent(dict["content"]!)
                    )
                case "Range":
                    return RangeExpr(
                        start: makeComponent(dict["start"]!),
                        end: makeComponent(dict["end"]!)
                    )
                default:
                return Directive(
                    type: type,
                    props: (dict["props"] as? [String: Any] ?? [:]).mapValues(makeComponent),
                    children: (dict["children"] as? [Any] ?? []).map(makeComponent)
                )
            }
        } else {
            return dict.mapValues(makeComponent)
        }
    default:
        fatalError("Unhandled type: \(any)")
    }
}

extension Component {
    public var jsonString: String {
        var converter = JSONConverter()
        let json = accept(&converter)
        let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed, .prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8)!
    }
}

extension AnyComponent {
    public init(from json: String) {
        let data = json.data(using: .utf8)!
        let any = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        self.init(makeComponent(any))
    }
}
