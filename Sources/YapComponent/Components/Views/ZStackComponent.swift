import SwiftUI

public struct ZStackComponent: AutomaticComponentConvertible {
    public var alignment: AlignmentComponent = .center
    public var content: ComponentProtocol = EmptyComponent()
    
    public init(alignment: AlignmentComponent, content: ComponentProtocol) {
        self.alignment = alignment
        self.content = content
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("alignment", \Self.alignment),
            ("content", \Self.content)
        ]
    }
}

extension ZStackComponent: View {
    public var body: some View {
        ZStack(alignment: alignment.swiftUI) {
            ComponentView(content)
        }
    }
}
