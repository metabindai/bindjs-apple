import SwiftUI

public struct UnitPointComponent: AutomaticComponentConvertible {
    var x: Double = 0.0
    var y: Double = 0.0
    
    public init() {}
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("x", \Self.x),
            ("y", \Self.y)
        ]
    }
}

public extension UnitPointComponent {
    static let center = UnitPointComponent(x: 0.5, y: 0.5)
    static let topLeading = UnitPointComponent(x: 0, y: 0)
    static let top = UnitPointComponent(x: 0.5, y: 0)
    static let topTrailing = UnitPointComponent(x: 1, y: 0)
    static let leading = UnitPointComponent(x: 0, y: 0.5)
    static let trailing = UnitPointComponent(x: 1, y: 0.5)
    static let bottomLeading = UnitPointComponent(x: 0, y: 1)
    static let bottom = UnitPointComponent(x: 0.5, y: 1)
    static let bottomTrailing = UnitPointComponent(x: 1, y: 1)
    static let zero = UnitPointComponent(x: 0, y: 0)
}

extension UnitPointComponent {
    var swiftUI: UnitPoint {
        UnitPoint(x: x, y: y)
    }
}
