import SwiftUI

public struct LinearGradientComponent: AutomaticComponentConvertible {
    public var colorComponents: [ColorComponent] {
        get { colors.compactMap { $0 as? Component }.compactMap { convertComponent($0) as? ColorComponent } }
        set { colors = newValue.map(\.component) }
    }
    public var colors: [ComponentProtocol] = []
    public var startPoint: UnitPointComponent = .topLeading
    public var endPoint: UnitPointComponent = .bottomTrailing
    
    public init() {}
    
    public init(colors: [ColorComponent], startPoint: UnitPointComponent = .topLeading, endPoint: UnitPointComponent = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("colors", \Self.colors),
            ("startPoint", \Self.startPoint),
            ("endPoint", \Self.endPoint)
        ]
    }
}

extension LinearGradientComponent: View {
    var swiftUI: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: colorComponents.map(\.swiftUI)),
            startPoint: startPoint.swiftUI,
            endPoint: endPoint.swiftUI
        )
    }
    
    public var body: some View {
        swiftUI
    }
}
