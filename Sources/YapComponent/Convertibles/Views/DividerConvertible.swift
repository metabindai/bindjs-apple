import SwiftUI

struct DividerConvertible: ComponentConvertible {
    init(_ component: Component) {
        
    }
    
    var component: Component {
        Component(type: Self.componentName)
    }
}

extension DividerConvertible: View {
    
    var body: some View {
        Divider()
    }
}
