import SwiftUI

struct AspectRatioConvertible: ComponentConvertible {
    
    let aspectRatio: Double?
    let contentMode: String
    
    init(_ component: Component) {
        aspectRatio = component.decode("aspectRatio") ?? component.decode("value")
        contentMode = component.decode("contentMode") ?? "fit"
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
        content.aspectRatio(aspectRatio.map { CGFloat($0) }, contentMode: .init(stringValue: contentMode))
    }
}

extension ContentMode {
    init(stringValue: String) {
        switch stringValue {
        case "fit":
            self = .fit
        case "fill":
            self = .fill
        default:
            self = .fit
        }
    }
}
