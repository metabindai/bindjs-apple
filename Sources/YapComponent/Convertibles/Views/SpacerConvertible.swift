import SwiftUI

struct SpacerConvertible: ComponentConvertible {
    let minLength: Double?
    
    init(_ component: Component) {
        minLength = component.decode("minLength")
    }
    
    var component: Component {
        if let minLength = minLength {
            return Component(
                type: Self.componentName,
                props: [
                    "minLength": minLength
                ]
            )
        } else {
            return Component(
                type: Self.componentName
            )
        }
    }
}

extension SpacerConvertible: View {
    
    var body: some View {
        if let minLength = minLength {
            Spacer(minLength: minLength)
        } else {
            Spacer()
        }
    }
}
