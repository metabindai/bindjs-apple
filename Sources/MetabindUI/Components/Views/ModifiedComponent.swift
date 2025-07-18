import SwiftUI

struct ModifiedComponent: Component {
    static var directiveName: String = "ModifiedComponent"
    
    let content: [Component]
    let modifier: Component
}

extension ModifiedComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        content = directive["content"].compactMap { makeComponent($0) }
        modifier = directive["modifier"].flatMap { makeComponent($0) } ?? EmptyComponent()
    }
}

extension ModifiedComponent: View {
    var body: some View {
        ForEach(content.indices, id: \.self) { index in
            ComponentView(content[index])
        }
        .modifier(ComponentViewModifier(modifier))
    }
}

extension Directive {
    func modifier(_ m: Directive) -> Directive {
        Directive(
            type: "ModifiedComponent",
            props: [
                "content": [self],
                "modifier": m
            ],
            children: []
        )
    }
}

struct EmptyComponent: Component {
    static var directiveName: String = "EmptyComponent"
    
    init() {}
}

extension EmptyComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
    }
}

extension EmptyComponent: View {
    var body: some View {
        EmptyView()
    }
}
