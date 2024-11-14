import SwiftUI

struct ProgressViewConvertible: ComponentConvertible {
    let value: Double?
    let total: Double?
    
    init(_ component: Component) {
        value = component.decode("value")
        total = component.decode("total")
    }
    
    var component: Component {
        if let value, let total {
            return Component(
                type: Self.componentName,
                props: [
                    "value": value,
                    "total": total
                ]
            )
        } else {
            return Component(
                type: Self.componentName
            )
        }
    }
}

extension ProgressViewConvertible: View {
    
    var body: some View {
        if let value = value, let total = total {
            ProgressView(value: value, total: total)
        } else {
            ProgressView()
        }
    }
}
