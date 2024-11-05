struct MaskComponent: AutomaticComponentConvertible {
    var content: ComponentProtocol = EmptyComponent()
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.content)
        ]
    }
}
