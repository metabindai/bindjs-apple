import SwiftUI

struct MaterialComponent: Component {
    static var directiveName: String = "Material"
    
    let material: Material
}

extension MaterialComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        guard let material: Material = directive.rawValue() else { return nil }
        
        self.material = material
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
