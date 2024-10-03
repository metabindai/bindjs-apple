import SwiftUI
import YapComponent

struct ShapeView: View {
    
    enum Name: String, CaseIterable {
        case Circle
        case Rectangle
        case Ellipse
        case Capsule
        case RoundedRectangle
    }
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        switch Name(rawValue: directive.type) {
        case .Circle: Circle()
        case .Rectangle: Rectangle()
        case .Ellipse: Ellipse()
        case .Capsule: Capsule()
        case .RoundedRectangle: RoundedRectangle(cornerRadius: props.cornerRadius ?? props._0 ?? 8)
        case .none: EmptyView()
        }
    }
    
}
