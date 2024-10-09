import SwiftUI

struct ComponentViewModifier: ViewModifier {
    
    @Environment(\.componentContext) private var context
    
    let component: ComponentProtocol
    
    init(_ component: ComponentProtocol) {
        self.component = component
    }
    
    func body(content: Content) -> some View {
        switch component.caseInViewModifierEnum(context) {
        
        case .frame(let frameComponent):
            content.modifier(frameComponent)
        
        case .flexFrame(let flexFrameComponent):
            content.modifier(flexFrameComponent)
        
        case .padding(let paddingComponent):
            content.modifier(paddingComponent)
        
        case .background(let backgroundComponent):
            content.background(ComponentView(backgroundComponent.content))
        
        case .buttonStyle(let buttonStyle):
            content.modifier(buttonStyle)
        
        case .overlay(let overlayComponent):
            content.overlay(ComponentView(overlayComponent.content))
        
        case .mask(let maskComponent):
            content.mask(ComponentView(maskComponent.content))
        
        case .aspectRatio(let aspectRatioComponent):
            content.modifier(aspectRatioComponent)
        
        case .scaledToFit:
            content.scaledToFit()
        
        case .scaledToFill:
            content.scaledToFill()
        
        case .position(let positionComponent):
            content.position(x: positionComponent.x, y: positionComponent.y)
        
        case .zIndex(let zIndexComponent):
            content.zIndex(zIndexComponent.value)
        
        case .hidden(let hiddenComponent):
            content.modifier(hiddenComponent)
        
        case .fontSize(let fontSizeComponent):
            content.modifier(fontSizeComponent)
        
        case .fontStyle(let fontStyleComponent):
            content.modifier(fontStyleComponent)
        
        case .fontWeight(let fontWeightComponent):
            content.modifier(fontWeightComponent)
        
        case .fontDesign(let fontDesignComponent):
            content.modifier(fontDesignComponent)
        
        case .kerning(let kerningComponent):
            content.modifier(kerningComponent)
        
        case .tracking(let trackingComponent):
            content.modifier(trackingComponent)
        
        case .bold(let boldComponent):
            content.modifier(boldComponent)
        
        case .italic(let italicComponent):
            content.modifier(italicComponent)
        
        case .multiLineTextAlignment(let multiLineTextAlignmentComponent):
            content.modifier(multiLineTextAlignmentComponent)
        
        case .lineLimit(let lineLimitComponent):
            content.lineLimit(lineLimitComponent.value)
        
        case .scaleEffect(let scaleEffectComponent):
            content.modifier(scaleEffectComponent)
        
        case .rotationEffect(let rotationEffectComponent):
            content.modifier(rotationEffectComponent)
        
        case .offset(let offsetComponent):
            content.modifier(offsetComponent)
        
        case .shadow(let shadowComponent):
            content.modifier(shadowComponent)
        
        case .border(let borderComponent):
            content.modifier(borderComponent)
        
        case .blur(let blurComponent):
            content.blur(radius: blurComponent.radius)
        
        case .opacity(let opacityComponent):
            content.opacity(opacityComponent.value)
        
        case .cornerRadius(let cornerRadiusComponent):
            content.modifier(cornerRadiusComponent)
        
        case .ignoresSafeArea(let ignoresSafeAreaComponent):
            content.modifier(ignoresSafeAreaComponent)
        
        case .disabled(let disabledComponent):
            content.disabled(disabledComponent.isActive)
        
        case .compositingGroup:
            content.compositingGroup()
        
        case .foregroundStyle(let foregroundStyleComponent):
            content.modifier(ForegroundStyleComponentModifier(foregroundStyleComponent))
        
        case .accessibilityLabel(let accessibilityLabelComponent):
            if let value = accessibilityLabelComponent.value {
                content.accessibilityLabel(value)
            } else {
                content
            }
        
        case .none:
            content
        }
    }
}
