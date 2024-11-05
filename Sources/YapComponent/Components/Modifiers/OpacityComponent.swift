struct OpacityComponent: AutomaticComponentConvertible {
    var value: Double = 1.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.value)
        ]
    }
}
