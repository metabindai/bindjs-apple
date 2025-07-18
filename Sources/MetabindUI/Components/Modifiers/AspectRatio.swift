import SwiftUI

struct AspectRatioComponent: Component {
    static var directiveName: String = "aspectRatio"
    
    let aspectRatio: CGFloat?
    let contentMode: ContentMode
}

extension AspectRatioComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        self.aspectRatio = directive["aspectRatio"]
        self.contentMode = directive["contentMode"] ?? .fill
    }
}

extension AspectRatioComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(aspectRatio, contentMode: contentMode)
    }
}
