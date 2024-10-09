struct DisabledComponent: AutomaticComponentConvertible {
    var isActive: Bool = false
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("isActive", \DisabledComponent.isActive)
        ]
    }
}
