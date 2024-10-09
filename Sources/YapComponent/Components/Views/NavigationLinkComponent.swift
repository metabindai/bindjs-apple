import SwiftUI

public struct NavigationLinkComponent: AutomaticComponentConvertible {
    public var value: String = ""
    public var label: ComponentProtocol = EmptyComponent()
    
    public init(value: String, label: ComponentProtocol) {
        self.value = value
        self.label = label
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("value", \Self.value),
            ("label", \Self.label)
        ]
    }
}

extension NavigationLinkComponent: View {
    public var body: some View {
        NavigationLink(value: value) {
            ComponentView(label)
        }
    }
}
