import SwiftUI

public struct ScrollViewComponent: AutomaticComponentConvertible {
    public var axes: AxisSetComponent = .vertical
    public var showsIndicators: Bool = true
    public var content: ComponentProtocol = EmptyComponent()
    
    public init(axes: AxisSetComponent, showsIndicators: Bool, content: ComponentProtocol) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("axes", \Self.axes),
            ("showsIndicators", \Self.showsIndicators),
            ("content", \Self.content)
        ]
    }
}

extension ScrollViewComponent: View {
    public var body: some View {
        ScrollView(axes.swiftUI, showsIndicators: showsIndicators) {
            ComponentView(content)
        }
    }
}
