import SwiftUI

public struct LinearGradientComponent: AutomaticComponentConvertible {
    public var colorComponents: [ColorComponent] {
        get { colors.compactMap { $0 as? Component }.compactMap { convertComponent($0) as? ColorComponent } }
        set { colors = newValue.map(\.component) }
    }
    public var colors: [ComponentProtocol] = []
    public var startPoint: String = "top"
    public var endPoint: String = "bottom"
    
    public init() {}
    
    public init(colors: [ColorComponent], startPoint: String = "top", endPoint: String = "bottom") {
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
            startPoint: startPoint.unitPoint,
            endPoint: endPoint.unitPoint
        )
    }
    
    public var body: some View {
        swiftUI
    }
}
