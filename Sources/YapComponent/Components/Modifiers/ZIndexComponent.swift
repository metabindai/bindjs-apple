struct ZIndexComponent: AutomaticComponentConvertible {
    var value: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.value)
        ]
    }
}
