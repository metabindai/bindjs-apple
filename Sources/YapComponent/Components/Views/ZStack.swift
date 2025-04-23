import SwiftUI

struct ZStackComponent: Component {
    static var directiveName: String = "ZStack"
    
    let alignment: Alignment
    let children: [Component]
}

extension ZStackComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        alignment = directive["alignment"] ?? .center
        children = directive.children.compactMap { makeComponent($0) }
    }
}

extension ZStackComponent: View {
    var body: some View {
        ZStack(alignment: alignment) {
            ForEach(children.indices, id: \.self) { index in
                ComponentView(children[index])
            }
        }
    }
}
