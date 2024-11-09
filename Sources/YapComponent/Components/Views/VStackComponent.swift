import SwiftUI

public struct VStackComponent: AutomaticComponentConvertible {
    public var alignment: String = "center"
    public var spacing: Double?
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(alignment: String = "center", spacing: Double? = nil, children: ComponentProtocol) {
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
        VStackLayout(alignment: _alignment, spacing: spacing.flatMap { CGFloat($0) }) {
            ComponentView(children)
        }
    }
    
    public var _alignment: HorizontalAlignment {
        switch alignment {
        case "leading": .leading
        case "center": .center
        case "trailing": .trailing
        default: .center
        }
    }
}
