import SwiftUI

struct LineLimitConvertible: ComponentConvertible {
    let lines: Int
    
    init(_ component: Component) {
        let linesDouble: Double = component.decode("value") ?? 0
        lines = Int(linesDouble.rounded())
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "value": Double(lines)
        ])
    }
}

extension LineLimitConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.lineLimit(lines)
    }
}
