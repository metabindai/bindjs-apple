//
//  ComponentEnum.swift
//  TypeProps3rdPasss
//
//  Created by Ollie Wagner on 10/6/24.
//

import Foundation

enum ComponentViewEnum {
    // Primitives and control flow
    case string(String)
    case array([ComponentProtocol])
    case binary(Binary)
    case defaults(Defaults)
    case variable(Variable)
    case conditional(ConditionalComponent)
    case forEach(ForEachComponent)
    case component(Component)
    case modified(ModifiedComponent)
    
    // Built-ins
    case button(ButtonComponent)
    case capsule(CapsuleComponent)
    case circle(CircleComponent)
    case color(ColorComponent)
    case divider(DividerComponent)
    case ellipse(EllipseComponent)
    case hStack(HStackComponent)
    case image(ImageComponent)
    case linearGradient(LinearGradientComponent)
    case list(ListComponent)
    case navigationLink(NavigationLinkComponent)
    case progress(ProgressComponent)
    case rectangle(RectangleComponent)
    case roundedRectangle(RoundedRectangleComponent)
    case scrollView(ScrollViewComponent)
    case spacer(SpacerComponent)
    case text(TextComponent)
    case vStack(VStackComponent)
    case zStack(ZStackComponent)
}

enum ComponentViewModifierEnum {
    case accessibilityLabel(AccessibilityLabelComponent)
    case aspectRatio(AspectRatioComponent)
    case background(BackgroundComponent)
    case blur(BlurComponent)
    case bold(BoldComponent)
    case border(BorderComponent)
    case buttonStyle(ButtonStyleComponent)
    case compositingGroup(CompositingGroupComponent)
    case cornerRadius(CornerRadiusComponent)
    case disabled(DisabledComponent)
    case flexFrame(FlexFrameComponent)
    case fontDesign(FontDesignComponent)
    case fontSize(FontSizeComponent)
    case fontStyle(FontStyleComponent)
    case fontWeight(FontWeightComponent)
    case foregroundStyle(ForegroundStyleComponent)
    case frame(FrameComponent)
    case hidden(HiddenComponent)
    case ignoresSafeArea(IgnoresSafeAreaComponent)
    case italic(ItalicComponent)
    case kerning(KerningComponent)
    case lineLimit(LineLimitComponent)
    case mask(MaskComponent)
    case multiLineTextAlignment(MultiLineTextAlignmentComponent)
    case offset(OffsetComponent)
    case opacity(OpacityComponent)
    case overlay(OverlayComponent)
    case padding(PaddingComponent)
    case position(PositionComponent)
    case rotationEffect(RotationEffectComponent)
    case scaledToFill(ScaledToFillComponent)
    case scaledToFit(ScaledToFitComponent)
    case scaleEffect(ScaleEffectComponent)
    case shadow(ShadowComponent)
    case tracking(TrackingComponent)
    case zIndex(ZIndexComponent)
}

extension ComponentConvertible {
    static var componentName: String {
        "\(Self.self)".replacingOccurrences(of: "Component", with: "")
    }
    
    var component: Component {
        let mirror = Mirror(reflecting: self)
        var props: [String: ComponentProtocol] = [:]
        
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            if let value = child.value as? ComponentProtocol {
                props[label] = value
            }
        }
        
        return Component(type: Self.componentName, props: props)
    }
}
