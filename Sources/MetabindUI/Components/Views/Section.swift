import SwiftUI

struct SectionComponent: Component {
    static var directiveName: String = "Section"
    
    let header: Component?
    let footer: Component?
    let content: [Component]
}

extension SectionComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.header = directive["header"].flatMap(makeComponent)
        self.footer = directive["footer"].flatMap(makeComponent)
        self.content = directive.children.compactMap { makeComponent($0) }
    }
}

extension SectionComponent: View {
    var body: some View {
        Section {
            ForEach(content.indices, id: \.self) { index in
                ComponentView(content[index])
            }
        } header: {
            if let header = header {
                ComponentView(header)
            }
        } footer: {
            if let footer = footer {
                ComponentView(footer)
            }
        }

    }
}
