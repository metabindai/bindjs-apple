import SwiftUI

public struct ComponentView: View {
    var component: AST
    
    init(_ component: AST) {
        self.component = component
    }
    
    public var body: some View {
        switch component {
            
        case is EmptyComponent:
            EmptyView()
            
        case let component as Component:
            CustomView(component)
            
        case let forEach as ForEachComponent:
            ForEachView(forEachComponent: forEach)
            
        case let modifiedComponent as ModifiedComponent:
            ComponentView(modifiedComponent.content)
                .modifier(ComponentViewModifier(modifiedComponent.modifier))
            
        case let array as [AST]:
            ForEach(array.indices, id: \.self) { index in
                ComponentView(array[index])
            }
            
        case let string as String:
            Text(string)
            
        case let anyView as AnyView:
            anyView
            
        // MARK: - Built-in Convertibles
            
        case let color as ColorConvertible:
            color
            
        case let text as TextConvertible:
            text
            
        case let circle as CircleConvertible:
            circle
            
        case let rectangle as RectangleConvertible:
            rectangle
            
        case let capsule as CapsuleConvertible:
            capsule
            
        case let ellipse as EllipseConvertible:
            ellipse
            
        case let scrollView as ScrollViewConvertible:
            scrollView
            
        case let button as ButtonConvertible:
            button
            
        case let progress as ProgressViewConvertible:
            progress
            
        case let list as ListConvertible:
            list
            
        case let hStack as HStackConvertible:
            hStack
            
        case let vStack as VStackConvertible:
            vStack
            
        case let zStack as ZStackConvertible:
            zStack
            
        case let lazyHStack as LazyHStackConvertible:
            lazyHStack
            
        case let lazyVStack as LazyVStackConvertible:
            lazyVStack
            
        case let spacer as SpacerConvertible:
            spacer
            
        case let divider as DividerConvertible:
            divider
            
        case let material as MaterialConvertible:
            material
            
        case let linearGradient as LinearGradientConvertible:
            linearGradient
            
        case let image as ImageConvertible:
            image
            
        case let toggle as ToggleConvertible:
            toggle
         
        case let label as LabelConvertible:
            label
            
        default:
            EmptyView()
        }
    }
}

public struct CustomView: View {
    @Environment(\.componentEnvironment) private var componentEnvironment
    
    let component: Component
    
    init(_ component: Component) {
        self.component = component
    }
    
    // Need to find out if I need to run convertComponent here or not.
    
    public var body: some View {
        if let value = componentEnvironment[component.type] {
            ComponentView(value)
        } else {
            ComponentView(component.children)
        }
    }
}
