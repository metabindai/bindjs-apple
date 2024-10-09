import SwiftUI

public struct HStackComponent: AutomaticComponentConvertible {
    public var alignment: VerticalAlignmentComponent = .center
    public var spacing: Double?
    public var content: ComponentProtocol = EmptyComponent()
    
    public init(alignment: VerticalAlignmentComponent, spacing: Double? = nil, content: ComponentProtocol) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("alignment", \Self.alignment),
            ("spacing", \Self.spacing),
            ("content", \Self.content)
        ]
    }
}

extension HStackComponent: View {
    public var body: some View {
        HStack(alignment: alignment.swiftUI, spacing: spacing.flatMap { CGFloat($0) }) {
            ComponentView(content)
        }
    }
}
