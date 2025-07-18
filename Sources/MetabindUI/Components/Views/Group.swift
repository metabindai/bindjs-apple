import SwiftUI

struct GroupComponent: Component {
    static var directiveName: String = "Group"
    
    let content: [Component]
}

extension GroupComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.content = directive.children.compactMap { makeComponent($0) }
    }
}

extension GroupComponent: View {
    var body: some View {
        Group {
            ForEach(content.indices, id: \.self) { index in
                ComponentView(content[index])
            }
        }
    }
}
