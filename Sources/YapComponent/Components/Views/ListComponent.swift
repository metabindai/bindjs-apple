import SwiftUI

public struct ListComponent: AutomaticComponentConvertible {
    public var content: ComponentProtocol = EmptyComponent()
    
    public init(content: ComponentProtocol) {
        self.content = content
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("content", \Self.content)
        ]
    }
}

extension ListComponent: View {
    public var body: some View {
        List {
            ComponentView(content)
        }
    }
}
