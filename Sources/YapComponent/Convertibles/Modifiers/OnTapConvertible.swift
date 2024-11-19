import SwiftUI

struct OnTapConvertible: ComponentConvertible {
    @Environment(\.componentRuntime) private var componentRuntime
    let handlerId: String
    
    init(_ component: Component) {
        handlerId = component.decode("handlerId") ?? ""
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "handlerId": handlerId
        ])
    }
}

extension OnTapConvertible: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture {
            componentRuntime.callEventHandler(id: handlerId, arguments: [])
        }
    }
}
