import SwiftUI

struct DrawingGroupConvertible: ComponentConvertible {
    
    init(_ component: Component) {
        
    }
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension DrawingGroupConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.drawingGroup()
    }
}
