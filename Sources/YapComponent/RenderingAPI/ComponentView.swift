import SwiftUI

public struct ComponentView: View {
    
    @Environment(\.componentContext) private var context
    let component: ComponentProtocol
    
    public init(_ component: ComponentProtocol) {
        self.component = component
    }
    
    public var body: some View {
        switch component.caseInViewEnum(context) {
        
        case .string(let string):
            Text(string)
        
        case .array(let array):
            ForEach(array.indices, id: \.self) { index in
                ComponentView(array[index])
            }
            
        case .binary(let binary):
            BinaryView(binary)
        
        case .defaults(let defaults):
            DefaultsView(defaults)
        
        case .variable(let variable):
            VariableView(variable)
        
        case .conditional(let conditionalComponent):
            ConditionalView(conditionalComponent)
        
        case .forEach(let forEachComponent):
            ForEachView(forEachComponent)
        
        case .component(let component):
            CustomView(component)
        
        case .modified(let modifiedComponent):
            ModifiedComponentView(modifiedComponent)
        
        case .text(let textComponent):
            textComponent
        
        case .button(let buttonComponent):
            ButtonComponentView(buttonComponent)
        
        case .image(let imageComponent):
            imageComponent
        
        case .divider:
            Divider()
        
        case .spacer:
            Spacer()
        
        case .progress(let progressComponent):
            progressComponent
        
        case .circle:
            Circle()
        
        case .ellipse:
            Ellipse()
        
        case .rectangle:
            Rectangle()
        
        case .capsule:
            Capsule(style: .continuous)
        
        case .roundedRectangle(let roundedRectangleComponent):
            roundedRectangleComponent
            
        case .color(let colorComponent):
            colorComponent
        
        case .linearGradient(let linearGradientComponent):
            linearGradientComponent
        
        case .navigationLink(let navigationLinkComponent):
            navigationLinkComponent
        
        case .vStack(let vStackComponent):
            vStackComponent
        
        case .hStack(let hStackComponent):
            hStackComponent
        
        case .zStack(let zStackComponent):
            zStackComponent
        
        case .scrollView(let scrollViewComponent):
            scrollViewComponent
        
        case .list(let listComponent):
            listComponent
            
        case .empty:
            Color.clear.hidden()
        
        case .none:
            switch component {
            case let anyView as AnyView:
                anyView
            default:
                Text("⚠️⚠️⚠️\n\nUnknown component: \(component)\n\n⚠️⚠️⚠️")
            }
        }
    }
}
