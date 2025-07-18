import SwiftUI

struct ContentShapeComponent: Component {
    static var directiveName: String = "contentShape"
    
    let shape: Shape?
}

extension ContentShapeComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.shape = directive.rawValue().flatMap { makeComponent($0) }.flatMap { makeShape($0) }
    }
}

extension ContentShapeComponent: ViewModifier {
    
    func body(content: Content) -> some View {
        if let shape = shape {
            content.contentShape(AnyShape(shape))
        } else {
            content
        }
    }
}
