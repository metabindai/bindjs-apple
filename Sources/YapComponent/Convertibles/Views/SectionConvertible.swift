import SwiftUI

struct SectionConvertible: ComponentConvertible {
    
    let header: AST
    let content: AST
    let footer: AST
    
    init(_ component: Component) {
        self.header = component.decodeAny("value") ?? component.decodeAny("header") ?? EmptyComponent()
        self.footer = component.decodeAny("footer") ?? EmptyComponent()
        self.content = component.children
    }
    
    var component: Component {
        return Component(
            type: Self.componentName,
            props: [
                "header": header,
                "content": content
            ],
            children: []
        )
    }
}

extension SectionConvertible: View {
    
    var body: some View {
        Section {
            ComponentView(content)
        } header: {
            ComponentView(header)
        } footer: {
            ComponentView(footer)
        }

    }
}
