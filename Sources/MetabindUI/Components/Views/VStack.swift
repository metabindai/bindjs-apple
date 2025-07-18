import SwiftUI

struct VStackComponent: Component {
    static var directiveName: String = "VStack"
    
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let children: [Component]
}

extension VStackComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        spacing = directive["spacing"]
        alignment = directive["alignment"] ?? .center
        children = directive.children.compactMap { makeComponent($0) }
    }
}

extension VStackComponent: View {
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(children.indices, id: \.self) { index in
                ComponentView(children[index])
            }
        }
    }
}
