struct AccessibilityLabelComponent: AutomaticComponentConvertible {
    var value: String?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
           ("value", \Self.value)
       ]
    }
}
