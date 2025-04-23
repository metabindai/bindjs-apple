import SwiftUI

struct DynamicTypeSizeComponent: Component {
    static var directiveName: String = "dynamicTypeSize"
    
    let dynamicTypeSize: DynamicTypeSize
}

extension DynamicTypeSizeComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        dynamicTypeSize = directive.rawValue() ?? .large
    }
}

extension DynamicTypeSizeComponent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(dynamicTypeSize)
    }
}
