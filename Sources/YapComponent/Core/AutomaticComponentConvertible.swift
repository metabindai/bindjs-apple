public protocol AutomaticComponentConvertible: ComponentConvertible {
    // Creates a base instance to write values into
    init()
    static var keyPaths: [(String, AnyKeyPath)] { get }
}

extension AutomaticComponentConvertible {
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        []
    }
    
    public init(_ component: Component) {
        var base = Self()
        for (key, path) in Self.keyPaths {
            if let value = component.props[key] {
                if let partialPath = path as? PartialKeyPath<Self> {
                    if let component = value as? Component {
                        decodeComponent(component).set(&base, at: partialPath)
                    } else {
                        value.set(&base, at: partialPath)
                    }
                }
            }
        }
        self = base
    }
    
    public var component: Component {
        var props: [String: ComponentProtocol] = [:]
        for (key, path) in Self.keyPaths {
            if let value = self[keyPath: path] as? ComponentConvertible {
                props[key] = value.component
            } else if let value = self[keyPath: path] as? [ComponentConvertible] {
                props[key] = value.map { $0.component }
            } else if let value = self[keyPath: path] as? ComponentProtocol {
                props[key] = value
            }
        }
        return .init(type: Self.componentName, props: props)
    }
}

extension ComponentProtocol {
    func set<Root: ComponentProtocol>(_ root: inout Root, at keyPath: PartialKeyPath<Root>) {
        if let writableKeyPath = keyPath as? WritableKeyPath<Root, Self> {
            root[keyPath: writableKeyPath] = self
        } else if let optionalKeyPath = keyPath as? WritableKeyPath<Root, Self?> {
            root[keyPath: optionalKeyPath] = self
        } else if let collectionKeyPath = keyPath as? WritableKeyPath<Root, [Self]>, let collection = self as? [Self] {
            root[keyPath: collectionKeyPath] = collection
        } else if let anyComponentProtocolKeyPath = keyPath as? WritableKeyPath<Root, any ComponentProtocol> {
            root[keyPath: anyComponentProtocolKeyPath] = self
        } else if
            let losslessConvertibleType = type(of: keyPath).valueType as? any LosslessStringConvertible.Type,
            let convertedValue = losslessConvertibleType.init(String(describing: self)) as? ComponentProtocol
        {
            convertedValue.set(&root, at: keyPath)
        } else {
            // Advanced type handling for edge cases
            if let mangledTypeName = _mangledTypeName(type(of: keyPath).valueType),
               // See https://github.com/swiftlang/swift/blob/main/docs/ABI/Mangling.rst
               mangledTypeName.hasSuffix("Sg"), // Check if it's an optional type
               let nonOptionalType = _typeByName(String(mangledTypeName.dropLast(2))),
               let lSC = nonOptionalType as? LosslessStringConvertible.Type,
               case let stringValue = String(describing: self),
               let value = lSC.init(stringValue) as? ComponentProtocol
            {
                value.set(&root, at: keyPath)
            } else {
                print("Could not set \(self) at \(keyPath)")
            }
        }
    }
}
