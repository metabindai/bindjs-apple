import SwiftUI

public struct ButtonComponent: AutomaticComponentConvertible {
    var action: String = ""
    var label: ComponentProtocol = EmptyComponent()
    
    public init(action: String, label: ComponentProtocol) {
        self.action = action
        self.label = label
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("action", \Self.action),
            ("label", \Self.label),
            ("rawValue", \Self.label)
        ]
    }
}

struct ButtonComponentView: View {
    let buttonComponent: ButtonComponent
    
    init(_ buttonComponent: ButtonComponent) {
        self.buttonComponent = buttonComponent
    }
    
    var body: some View {
        Button(action: {
            print("PRESSED ACTION: \(buttonComponent.action)")
        }) {
            ComponentView(buttonComponent.label)
        }
    }
}
