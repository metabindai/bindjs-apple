import SwiftUI

public struct VStackComponent: AutomaticComponentConvertible {
    public var alignment: HorizontalAlignmentComponent = .center
    public var spacing: Double?
    public var content: ComponentProtocol = EmptyComponent()
    
    public init(alignment: HorizontalAlignmentComponent, spacing: Double? = nil, content: ComponentProtocol) {
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

extension VStackComponent: View {
    public var body: some View {
        VStack(alignment: alignment.swiftUI, spacing: spacing.flatMap { CGFloat($0) }) {
            ComponentView(content)
        }
    }
}
