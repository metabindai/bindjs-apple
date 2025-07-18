import SwiftUI

struct SpacerComponent: Component {
    static var directiveName: String = "Spacer"
    
    let minLength: CGFloat?
}

extension SpacerComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        minLength = directive["minLength"]
    }
}

extension SpacerComponent: View {
    var body: some View {
        Spacer(minLength: minLength)
    }
}
