import SwiftUI

public struct ZStackComponent: AutomaticComponentConvertible {
    public var alignment: String = "center"
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(alignment: String, children: ComponentProtocol) {
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
        ZStackLayout(alignment: alignment.alignment) {
            ComponentView(children)
        }
    }
}
