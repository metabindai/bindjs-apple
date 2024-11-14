import SwiftUI

struct AspectRatioConvertible: ComponentConvertible {
    
    let aspectRatio: Double?
    
    init(_ component: Component) {
        aspectRatio = component.decode("aspectRatio") ?? component.decode("value")
    }
    
    var component: Component {
        if let aspectRatio = aspectRatio {
            return Component(
                type: Self.componentName,
                props: [
                    "aspectRatio": aspectRatio
                ]
            )
        } else {
            return Component(
                type: Self.componentName
            )
        }
    }
}

extension AspectRatioConvertible: ViewModifier {
    
    public func body(content: Content) -> some View {
        if let aspectRatio = aspectRatio {
            content.aspectRatio(CGFloat(aspectRatio), contentMode: .fit)
        } else {
            content
        }
    }
}
