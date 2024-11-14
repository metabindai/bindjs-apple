import SwiftUI

struct MultilineTextAlignmentConvertible: ComponentConvertible {
    let alignment: String
    
    init(_ component: Component) {
        alignment = component.decode("value") ?? "leading"
    }
    
    var component: Component {
        return Component(
            type: Self.componentName,
            props: ["value": alignment]
        )
    }
}

extension MultilineTextAlignmentConvertible: ViewModifier {
    var swiftUI: TextAlignment {
        switch self.alignment {
        case "leading":
            return .leading
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
    }
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(swiftUI)
    }
}
