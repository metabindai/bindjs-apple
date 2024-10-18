import SwiftUI

public struct VStackComponent: AutomaticComponentConvertible {
    public var alignment: HorizontalAlignmentComponent = .center
    public var spacing: Double?
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(alignment: HorizontalAlignmentComponent, spacing: Double? = nil, children: ComponentProtocol) {
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

extension VStackComponent: View {
    public var body: some View {
        VStack(alignment: alignment.swiftUI, spacing: spacing.flatMap { CGFloat($0) }) {
            ComponentView(children)
        }
    }
}
