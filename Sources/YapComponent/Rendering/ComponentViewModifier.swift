//
//  ComponentViewModifier.swift
//  JSYapRuntime
//
//  Created by Ollie Wagner on 11/13/24.
//

import SwiftUI

struct ComponentViewModifier: ViewModifier {
    var modifier: AST
    
    init(_ modifier: AST) {
        self.modifier = modifier
    }
    
    func body(content: Content) -> some View {
        switch modifier {
        
        case let accessibilityLabel as AccessibilityLabelConvertible:
            content.modifier(accessibilityLabel)
        
        case let aspectRatio as AspectRatioConvertible:
            content.modifier(aspectRatio)
        
        case let background as BackgroundConvertible:
            content.modifier(background)
        
        case let blendMode as BlendModeConvertible:
            content.modifier(blendMode)
        
        case let blur as BlurConvertible:
            content.modifier(blur)
        
        case let bold as BoldConvertible:
            content.modifier(bold)
        
        case let border as BorderConvertible:
            content.modifier(border)
        
        case let buttonStyle as ButtonStyleConvertible:
            content.modifier(buttonStyle)
        
        case let compositingGroup as CompositingGroupConvertible:
            content.modifier(compositingGroup)
        
        case let cornerRadius as CornerRadiusConvertible:
            content.modifier(cornerRadius)
        
        case let disabled as DisabledConvertible:
            content.modifier(disabled)
        
        case let flexFrame as FlexFrameConvertible:
            content.modifier(flexFrame)
        
        case let font as FontConvertible:
            content.modifier(font)
        
        case let fontDesign as FontDesignConvertible:
            content.modifier(fontDesign)
        
        case let fontWeight as FontWeightConvertible:
            content.modifier(fontWeight)
        
        case let foregroundStyle as ForegroundStyleConvertible:
            content.modifier(foregroundStyle)
        
        case let frame as FrameConvertible:
            content.modifier(frame)
        
        case let hidden as HiddenConvertible:
            content.modifier(hidden)
        
        case let ignoresSafeArea as IgnoresSafeAreaConvertible:
            content.modifier(ignoresSafeArea)
        
        case let italic as ItalicConvertible:
            content.modifier(italic)
        
        case let kerning as KerningConvertible:
            content.modifier(kerning)
        
        case let labelStyle as LabelStyleConvertible:
            content.modifier(labelStyle)
        
        case let lineLimit as LineLimitConvertible:
            content.modifier(lineLimit)
        
        case let mask as MaskConvertible:
            content.modifier(mask)
        
        case let multilineTextAlignment as MultilineTextAlignmentConvertible:
            content.modifier(multilineTextAlignment)
        
        case let offset as OffsetConvertible:
            content.modifier(offset)
        
        case let opacity as OpacityConvertible:
            content.modifier(opacity)
        
        case let overlay as OverlayConvertible:
            content.modifier(overlay)
        
        case let padding as PaddingConvertible:
            content.modifier(padding)
        
        case let position as PositionConvertible:
            content.modifier(position)
        
        case let progressViewStyle as ProgressViewStyleConvertible:
            content.modifier(progressViewStyle)
        
        case let rotationEffect as RotationEffectConvertible:
            content.modifier(rotationEffect)
        
        case let scaleEffect as ScaleEffectConvertible:
            content.modifier(scaleEffect)
        
        case let scaledToFill as ScaledToFillConvertible:
            content.modifier(scaledToFill)
        
        case let scaledToFit as ScaledToFitConvertible:
            content.modifier(scaledToFit)
        
        case let shadow as ShadowConvertible:
            content.modifier(shadow)
        
        case let toggleStyle as ToggleStyleConvertible:
            content.modifier(toggleStyle)
        
        case let tracking as TrackingConvertible:
            content.modifier(tracking)
        
        case let zIndex as ZIndexConvertible:
            content.modifier(zIndex)
        
        default:
            content
        }
    }
}
