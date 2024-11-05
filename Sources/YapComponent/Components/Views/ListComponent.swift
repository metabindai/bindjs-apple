import SwiftUI

public struct ListComponent: AutomaticComponentConvertible {
    public var children: ComponentProtocol = EmptyComponent()
    
    public init(children: ComponentProtocol) {
        self.children = children
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("children", \Self.children),
        ]
    }
}

extension ListComponent: View {
    public var body: some View {
        List {
            ComponentView(children)
        }
    }
}
