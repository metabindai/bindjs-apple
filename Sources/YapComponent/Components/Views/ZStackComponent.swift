import SwiftUI

public struct ZStackComponent: AutomaticComponentConvertible {
    public var alignment: AlignmentComponent = .center
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(alignment: AlignmentComponent, children: ComponentProtocol) {
        self.alignment = alignment
        self.children = children
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("alignment", \Self.alignment),
            ("children", \Self.children)
        ]
    }
}

extension ZStackComponent: View {
    public var body: some View {
        ZStack(alignment: alignment.swiftUI) {
            ComponentView(children)
        }
    }
}
