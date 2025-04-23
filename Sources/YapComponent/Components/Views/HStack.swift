import SwiftUI

struct HStackComponent: Component {
    static var directiveName: String = "HStack"
    
    let alignment: VerticalAlignment
    let spacing: CGFloat?
    let children: [Component]
}

extension HStackComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        spacing = directive["spacing"]
        alignment = directive["alignment"] ?? .center
        children = directive.children.compactMap { makeComponent($0) }
    }
}

extension HStackComponent: View {
    var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            ForEach(children.indices, id: \.self) { index in
                ComponentView(children[index])
            }
        }
    }
}
