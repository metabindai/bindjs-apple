import SwiftUI

struct LabelConvertible: ComponentConvertible {
    let title: AST
    let icon: AST
    
    init(_ component: Component) {
        title = component.decodeAny("title") ?? EmptyComponent()
        icon = component.decodeAny("icon") ?? EmptyComponent()
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "title": title,
                "icon": icon
            ]
        )
    }
}

extension LabelConvertible: View {
    var body: some View {
        Label(title: {
            ComponentView(title)
        }, icon: {
            ComponentView(icon)
        })
    }
}
