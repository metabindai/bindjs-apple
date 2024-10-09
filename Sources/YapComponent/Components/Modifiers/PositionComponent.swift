struct PositionComponent: AutomaticComponentConvertible {
    var x: Double = 0.0
    var y: Double = 0.0
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("x", \Self.x),
            ("y", \Self.y)
        ]
    }
}
