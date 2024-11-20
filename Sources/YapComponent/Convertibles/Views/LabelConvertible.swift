import SwiftUI

struct LabelConvertible: ComponentConvertible {
    let title: String
    let icon: AST
    
    init(_ component: Component) {
        title = component.decode("title") ?? ""
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
            Text(title)
        }, icon: {
            ComponentView(icon)
        })
    }
}
