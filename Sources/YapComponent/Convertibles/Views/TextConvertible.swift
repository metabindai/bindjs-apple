import SwiftUI

struct TextConvertible: ComponentConvertible {
    let text: String
    
    init(_ component: Component) {
        text = component.decode("value") ?? component.decode("text") ?? ""
    }
    
    var component: Component {
        Component(type: Self.componentName, props: [
            "text": text
        ])
    }
}

extension TextConvertible: View {
    
    var body: some View {
        Text(LocalizedStringKey(text))
    }
}

