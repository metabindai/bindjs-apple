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
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            NavigationLink(value: value) {
                ComponentView(label)
            }
        } else {
            ComponentView(label)
        }
    }
}
