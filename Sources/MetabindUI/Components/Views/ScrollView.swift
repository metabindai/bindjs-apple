import SwiftUI

struct ScrollViewComponent: Component {
    static var directiveName: String = "ScrollView"
    
    let axis: Axis.Set
    let showsIndicators: Bool
    let content: [Component]
}

extension ScrollViewComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        axis = directive["axis"] ?? .vertical
        showsIndicators = directive["showsIndicators"] ?? true
        content = directive.children.compactMap { makeComponent($0) }
    }
}

extension ScrollViewComponent: View {
    var body: some View {
        ScrollView(axis, showsIndicators: showsIndicators) {
            ForEach(content.indices, id: \.self) { index in
                ComponentView(content[index])
            }
        }
    }
}
