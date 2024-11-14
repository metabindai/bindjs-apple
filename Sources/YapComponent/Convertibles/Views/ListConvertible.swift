import SwiftUI

struct ListConvertible: ComponentConvertible {
    let children: AST
    
    init(_ component: Component) {
        children = component.children
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "children": children
        ])
    }
}

extension ListConvertible: View {
    var body: some View {
        List {
            ComponentView(children)
        }
    }
}
