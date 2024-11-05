struct LineLimitComponent: AutomaticComponentConvertible {
    var value: Int = 1
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.value)
        ]
    }
}
