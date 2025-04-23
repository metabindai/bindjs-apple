import SwiftUI

struct MaterialComponent: Component {
    static var directiveName: String = "Material"
    
    let material: Material
}

extension MaterialComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        material = directive.rawValue() ?? .regular
    }
}

extension MaterialComponent: View {
    var swiftUI: Material {
        material
    }
    
    var body: some View {
        Rectangle().fill(swiftUI)
    }
}
