import SwiftUI

public struct ScrollViewComponent: AutomaticComponentConvertible {
    public var axes: String = "vertical"
    public var showsIndicators: Bool = true
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(axes: String, showsIndicators: Bool, children: ComponentProtocol) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.children = children
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("axes", \Self.axes),
            ("showsIndicators", \Self.showsIndicators),
            ("children", \Self.children)
        ]
    }
}

extension ScrollViewComponent: View {
    public var body: some View {
        ScrollView(axes.axisSet, showsIndicators: showsIndicators) {
            ComponentView(children)
        }
    }
}
