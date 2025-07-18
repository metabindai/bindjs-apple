import SwiftUI

struct IgnoresSafeAreaComponent: Component {
    static var directiveName: String = "ignoresSafeArea"
    
    let regions: SafeAreaRegions?
    let edges: Edge.Set?
}

extension IgnoresSafeAreaComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        regions = directive["regions"]
        edges = directive["edges"]
    }
}

extension IgnoresSafeAreaComponent: ViewModifier {
    func body(content: Content) -> some View {
        if let regions = regions, let edges = edges {
            content.ignoresSafeArea(regions, edges: edges)
        } else if let regions = regions {
            content.ignoresSafeArea(regions)
        } else if let edges = edges {
            content.ignoresSafeArea(.all, edges: edges)
        } else {
            content.ignoresSafeArea()
        }
    }
}