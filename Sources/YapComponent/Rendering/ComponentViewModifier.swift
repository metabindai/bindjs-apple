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
        
        case let blur as BlurConvertible:
            content.modifier(blur)
            
        case let shadow as ShadowConvertible:
            content.modifier(shadow)
            
        case let buttonStyle as ButtonStyleConvertible:
            content.modifier(buttonStyle)
            
        case let toggleStyle as ToggleStyleConvertible:
            content.modifier(toggleStyle)
            
        case let scaleEffect as ScaleEffectConvertible:
            content.modifier(scaleEffect)
            
        case let frame as FrameConvertible:
            content.modifier(frame)
            
        case let flexFrame as FlexFrameConvertible:
            content.modifier(flexFrame)
            
        case let cornerRadius as CornerRadiusConvertible:
            content.modifier(cornerRadius)
            
        case let offset as OffsetConvertible:
            content.modifier(offset)
            
        case let bold as BoldConvertible:
            content.modifier(bold)
            
        case let font as FontConvertible:
            content.modifier(font)
            
        case let italic as ItalicConvertible:
            content.modifier(italic)
            
        case let disabled as DisabledConvertible:
            content.modifier(disabled)
            
        case let hidden as HiddenConvertible:
            content.modifier(hidden)
            
        case let opacity as OpacityConvertible:
            content.modifier(opacity)
            
        case let scaledToFit as ScaledToFitConvertible:
            content.modifier(scaledToFit)
            
        case let scaledToFill as ScaledToFillConvertible:
            content.modifier(scaledToFill)
            
        case let zIndex as ZIndexConvertible:
            content.modifier(zIndex)
            
        case let foregroundStyle as ForegroundStyleConvertible:
            content.modifier(foregroundStyle)
            
        case let tracking as TrackingConvertible:
            content.modifier(tracking)
            
        case let kerning as KerningConvertible:
            content.modifier(kerning)
            
        case let background as BackgroundConvertible:
            content.modifier(background)
            
        case let overlay as OverlayConvertible:
            content.modifier(overlay)
            
        case let mask as MaskConvertible:
            content.modifier(mask)
            
        case let lineLimit as LineLimitConvertible:
            content.modifier(lineLimit)
            
        case let accessibilityLabel as AccessibilityLabelConvertible:
            content.modifier(accessibilityLabel)
            
        case let position as PositionConvertible:
            content.modifier(position)
            
        case let fontDesign as FontDesignConvertible:
            content.modifier(fontDesign)
            
        case let aspectRatio as AspectRatioConvertible:
            content.modifier(aspectRatio)
            
        case let fontWeight as FontWeightConvertible:
            content.modifier(fontWeight)
            
        case let compositingGroup as CompositingGroupConvertible:
            content.modifier(compositingGroup)
            
        case let ignoresSafeArea as IgnoresSafeAreaConvertible:
            content.modifier(ignoresSafeArea)
            
        case let multilineTextAlignment as MultilineTextAlignmentConvertible:
            content.modifier(multilineTextAlignment)
            
        case let rotationEffect as RotationEffectConvertible:
            content.modifier(rotationEffect)
            
        case let border as BorderConvertible:
            content.modifier(border)
            
        case let padding as PaddingConvertible:
            content.modifier(padding)
            
        case let labelStyle as LabelStyleConvertible:
            content.modifier(labelStyle)
            
        case let progressViewStyle as ProgressViewStyleConvertible:
            content.modifier(progressViewStyle)
            
        default:
            content
        }
    }
}
