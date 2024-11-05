struct BlurComponent: AutomaticComponentConvertible {
    var radius: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.radius)
        ]
    }
}
