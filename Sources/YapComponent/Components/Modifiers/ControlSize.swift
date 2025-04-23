import SwiftUI

struct ControlSizeComponent: Component {
    static var directiveName: String = "controlSize"
    
    let controlSize: ControlSize
}

extension ControlSizeComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        controlSize = directive.rawValue() ?? .regular
    }
}

extension ControlSizeComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .controlSize(controlSize)
    }
}
