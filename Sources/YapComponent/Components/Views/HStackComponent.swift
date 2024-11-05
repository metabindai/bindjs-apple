import SwiftUI

public struct HStackComponent: AutomaticComponentConvertible {
    public var alignment: VerticalAlignmentComponent = .center
    public var spacing: Double?
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(alignment: VerticalAlignmentComponent, spacing: Double? = nil, children: ComponentProtocol) {
        self.alignment = alignment
        self.spacing = spacing
        self.children = children
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("alignment", \Self.alignment),
            ("spacing", \Self.spacing),
            ("children", \Self.children)
        ]
    }
}

extension HStackComponent: View {
    public var body: some View {
        HStack(alignment: alignment.swiftUI, spacing: spacing.flatMap { CGFloat($0) }) {
            ComponentView(children)
        }
    }
}
