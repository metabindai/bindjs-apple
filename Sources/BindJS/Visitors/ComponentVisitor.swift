public protocol ComponentVisitor {
    associatedtype Result
    
    mutating func visit(_ component: any Component) -> Result
    mutating func defaultVisit(_ component: any Component) -> Result
    
    // Views Components
    mutating func visitButton(_ button: ButtonComponent) -> Result
    mutating func visitCall(_ call: ComponentCall) -> Result
    mutating func visitColor(_ color: ColorComponent) -> Result
    mutating func visitDivider(_ divider: DividerComponent) -> Result
    mutating func visitForEach(_ forEach: ForEachComponent) -> Result
    mutating func visitGroup(_ group: GroupComponent) -> Result
    mutating func visitHStack(_ hStack: HStackComponent) -> Result
    mutating func visitImage(_ image: ImageComponent) -> Result
    mutating func visitMaterial(_ material: MaterialComponent) -> Result
    mutating func visitModel3D(_ model3D: Model3DComponent) -> Result
    mutating func visitModified(_ modified: ModifiedComponent) -> Result
    mutating func visitEmpty(_ empty: EmptyComponent) -> Result
    mutating func visitPicker(_ picker: PickerComponent) -> Result
    mutating func visitPlaceholder(_ placeholder: PlaceholderComponent) -> Result
    mutating func visitProgressView(_ progressView: ProgressViewComponent) -> Result
    mutating func visitScrollView(_ scrollView: ScrollViewComponent) -> Result
    mutating func visitSection(_ section: SectionComponent) -> Result
    mutating func visitSpacer(_ spacer: SpacerComponent) -> Result
    mutating func visitText(_ text: TextComponent) -> Result
    mutating func visitTextEditor(_ textEditor: TextEditorComponent) -> Result
    mutating func visitUnresolved(_ unresolved: UnresolvedComponent) -> Result
    mutating func visitVStack(_ vStack: VStackComponent) -> Result
    mutating func visitVideo(_ video: VideoComponent) -> Result
    mutating func visitZStack(_ zStack: ZStackComponent) -> Result
    
    // Gradient Components
    mutating func visitLinearGradient(_ linearGradient: LinearGradientComponent) -> Result
    mutating func visitAngularGradient(_ angularGradient: AngularGradientComponent) -> Result
    mutating func visitRadialGradient(_ radialGradient: RadialGradientComponent) -> Result
    mutating func visitEllipticalGradient(_ ellipticalGradient: EllipticalGradientComponent) -> Result
    
    // Shape Components
    mutating func visitCircle(_ circle: CircleComponent) -> Result
    mutating func visitEllipse(_ ellipse: EllipseComponent) -> Result
    mutating func visitRectangle(_ rectangle: RectangleComponent) -> Result
    mutating func visitRoundedRectangle(_ roundedRectangle: RoundedRectangleComponent) -> Result
    mutating func visitCapsule(_ capsule: CapsuleComponent) -> Result
    
    // Modifier Components
    mutating func visitAccessibilityHidden(_ accessibilityHidden: AccessibilityHiddenComponent) -> Result
    mutating func visitAccessibilityHint(_ accessibilityHint: AccessibilityHintComponent) -> Result
    mutating func visitAccessibilityLabel(_ accessibilityLabel: AccessibilityLabelComponent) -> Result
    mutating func visitAccessibilityRepresentation(_ accessibilityRepresentation: AccessibilityRepresentationComponent) -> Result
    mutating func visitAccessibilityValue(_ accessibilityValue: AccessibilityValueComponent) -> Result
    mutating func visitAccessibilityAddTraits(_ accessibilityAddTraits: AccessibilityAddTraitsComponent) -> Result
    mutating func visitAccessibilityRemoveTraits(_ accessibilityRemoveTraits: AccessibilityRemoveTraitsComponent) -> Result
    mutating func visitAllowsHitTesting(_ allowsHitTesting: AllowsHitTestingComponent) -> Result
    mutating func visitAllowsTightening(_ allowsTightening: AllowsTighteningComponent) -> Result
    mutating func visitAspectRatio(_ aspectRatio: AspectRatioComponent) -> Result
    mutating func visitBackground(_ background: BackgroundComponent) -> Result
    mutating func visitBlendMode(_ blendMode: BlendModeComponent) -> Result
    mutating func visitBlur(_ blur: BlurComponent) -> Result
    mutating func visitBold(_ bold: BoldComponent) -> Result
    mutating func visitBorder(_ border: BorderComponent) -> Result
    mutating func visitBrightness(_ brightness: BrightnessComponent) -> Result
    mutating func visitClipped(_ clipped: ClippedComponent) -> Result
    mutating func visitClipShape(_ clipShape: ClipShapeComponent) -> Result
    mutating func visitColorInvert(_ colorInvert: ColorInvertComponent) -> Result
    mutating func visitColorScheme(_ colorScheme: ColorSchemeComponent) -> Result
    mutating func visitContentShape(_ contentShape: ContentShapeComponent) -> Result
    mutating func visitContrast(_ contrast: ContrastComponent) -> Result
    mutating func visitControlSize(_ controlSize: ControlSizeComponent) -> Result
    mutating func visitCornerRadius(_ cornerRadius: CornerRadiusComponent) -> Result
    mutating func visitCoordinateSpace(_ coordinateSpace: CoordinateSpaceComponent) -> Result
    mutating func visitDisabled(_ disabled: DisabledComponent) -> Result
    mutating func visitAutocorrectionDisabled(_ autocorrectionDisabled: AutocorrectionDisabledComponent) -> Result
    mutating func visitDynamicTypeSize(_ dynamicTypeSize: DynamicTypeSizeComponent) -> Result
    mutating func visitFixedSize(_ fixedSize: FixedSizeComponent) -> Result
    mutating func visitFlexibleFrame(_ flexibleFrame: FlexibleFrameComponent) -> Result
    mutating func visitFont(_ font: FontComponent) -> Result
    mutating func visitFontCustom(_ fontCustom: FontCustomComponent) -> Result
    mutating func visitFontDesign(_ fontDesign: FontDesignComponent) -> Result
    mutating func visitFontWeight(_ fontWeight: FontWeightComponent) -> Result
    mutating func visitFontWidth(_ fontWidth: FontWidthComponent) -> Result
    mutating func visitForegroundStyle(_ foregroundStyle: ForegroundStyleComponent) -> Result
    mutating func visitFrame(_ frame: FrameComponent) -> Result
    mutating func visitPickerStyle(_ pickerStyle: PickerStyleComponent) -> Result
    mutating func visitGlassEffect(_ glassEffect: GlassEffectComponent) -> Result
    mutating func visitGrayscale(_ grayscale: GrayscaleComponent) -> Result
    mutating func visitHidden(_ hidden: HiddenComponent) -> Result
    mutating func visitID(_ id: IDComponent) -> Result
    mutating func visitIgnoresSafeArea(_ ignoresSafeArea: IgnoresSafeAreaComponent) -> Result
    mutating func visitItalic(_ italic: ItalicComponent) -> Result
    mutating func visitLayoutPriority(_ layoutPriority: LayoutPriorityComponent) -> Result
    mutating func visitLineLimit(_ lineLimit: LineLimitComponent) -> Result
    mutating func visitLineSpacing(_ lineSpacing: LineSpacingComponent) -> Result
    mutating func visitMask(_ mask: MaskComponent) -> Result
    mutating func visitMinimumScaleFactor(_ minimumScaleFactor: MinimumScaleFactorComponent) -> Result
    mutating func visitMonospaced(_ monospaced: MonospacedComponent) -> Result
    mutating func visitMultilineTextAlignment(_ multilineTextAlignment: MultilineTextAlignmentComponent) -> Result
    mutating func visitNavigationTitle(_ navigationTitle: NavigationTitleComponent) -> Result
    mutating func visitOffset(_ offset: OffsetComponent) -> Result
    mutating func visitOnAppear(_ onAppear: OnAppearComponent) -> Result
    mutating func visitOnDisappear(_ onDisappear: OnDisappearComponent) -> Result
    mutating func visitOnDragGesture(_ onDragGesture: OnDragGestureComponent) -> Result
    mutating func visitOnLongPressGesture(_ onLongPressGesture: OnLongPressGestureComponent) -> Result
    mutating func visitOnTapGesture(_ onTapGesture: OnTapGestureComponent) -> Result
    mutating func visitOpacity(_ opacity: OpacityComponent) -> Result
    mutating func visitOverlay(_ overlay: OverlayComponent) -> Result
    mutating func visitPadding(_ padding: PaddingComponent) -> Result
    mutating func visitRotationEffect(_ rotationEffect: RotationEffectComponent) -> Result
    mutating func visitSaturation(_ saturation: SaturationComponent) -> Result
    mutating func visitScaleEffect(_ scaleEffect: ScaleEffectComponent) -> Result
    mutating func visitScaledToFill(_ scaledToFill: ScaledToFillComponent) -> Result
    mutating func visitScaledToFit(_ scaledToFit: ScaledToFitComponent) -> Result
    mutating func visitShadow(_ shadow: ShadowComponent) -> Result
    mutating func visitStrikethrough(_ strikethrough: StrikethroughComponent) -> Result
    mutating func visitTag(_ tag: TagComponent) -> Result
    mutating func visitTextCase(_ textCase: TextCaseComponent) -> Result
    mutating func visitTextSelection(_ textSelection: TextSelectionComponent) -> Result
    mutating func visitTint(_ tint: TintComponent) -> Result
    mutating func visitTracking(_ tracking: TrackingComponent) -> Result
    mutating func visitTransformEffect(_ transformEffect: TransformEffectComponent) -> Result
    mutating func visitUnderline(_ underline: UnderlineComponent) -> Result
    mutating func visitVisualEffect(_ visualEffect: VisualEffectComponent) -> Result
    mutating func visitZIndex(_ zIndex: ZIndexComponent) -> Result
}

public extension ComponentVisitor {
    // Default visit is left out of the extension so that the compiler forces implementation of it in concrete conformances
    
    mutating func visit(_ component: any Component) -> Result {
        return component.accept(visitor: &self)
    }
    
    // Views Components Default Implementations
    mutating func visitButton(_ button: ButtonComponent) -> Result {
        return defaultVisit(button)
    }
    
    mutating func visitCall(_ call: ComponentCall) -> Result {
        return defaultVisit(call)
    }
    
    mutating func visitColor(_ color: ColorComponent) -> Result {
        return defaultVisit(color)
    }
    
    mutating func visitDivider(_ divider: DividerComponent) -> Result {
        return defaultVisit(divider)
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> Result {
        return defaultVisit(forEach)
    }
    
    mutating func visitGroup(_ group: GroupComponent) -> Result {
        return defaultVisit(group)
    }
    
    mutating func visitHStack(_ hStack: HStackComponent) -> Result {
        return defaultVisit(hStack)
    }
    
    mutating func visitImage(_ image: ImageComponent) -> Result {
        return defaultVisit(image)
    }
    
    mutating func visitMaterial(_ material: MaterialComponent) -> Result {
        return defaultVisit(material)
    }
    
    mutating func visitModel3D(_ model3D: Model3DComponent) -> Result {
        return defaultVisit(model3D)
    }
    
    mutating func visitModified(_ modified: ModifiedComponent) -> Result {
        return defaultVisit(modified)
    }
    
    mutating func visitEmpty(_ empty: EmptyComponent) -> Result {
        return defaultVisit(empty)
    }
    
    mutating func visitPicker(_ picker: PickerComponent) -> Result {
        return defaultVisit(picker)
    }
    
    mutating func visitPlaceholder(_ placeholder: PlaceholderComponent) -> Result {
        return defaultVisit(placeholder)
    }
    
    mutating func visitProgressView(_ progressView: ProgressViewComponent) -> Result {
        return defaultVisit(progressView)
    }
    
    mutating func visitScrollView(_ scrollView: ScrollViewComponent) -> Result {
        return defaultVisit(scrollView)
    }
    
    mutating func visitSection(_ section: SectionComponent) -> Result {
        return defaultVisit(section)
    }
    
    mutating func visitSpacer(_ spacer: SpacerComponent) -> Result {
        return defaultVisit(spacer)
    }
    
    mutating func visitText(_ text: TextComponent) -> Result {
        return defaultVisit(text)
    }
    
    mutating func visitTextEditor(_ textEditor: TextEditorComponent) -> Result {
        return defaultVisit(textEditor)
    }
    
    mutating func visitUnresolved(_ unresolved: UnresolvedComponent) -> Result {
        return defaultVisit(unresolved)
    }
    
    mutating func visitVStack(_ vStack: VStackComponent) -> Result {
        return defaultVisit(vStack)
    }
    
    mutating func visitVideo(_ video: VideoComponent) -> Result {
        return defaultVisit(video)
    }
    
    mutating func visitZStack(_ zStack: ZStackComponent) -> Result {
        return defaultVisit(zStack)
    }
    
    // Gradient Components Default Implementations
    mutating func visitLinearGradient(_ linearGradient: LinearGradientComponent) -> Result {
        return defaultVisit(linearGradient)
    }
    
    mutating func visitAngularGradient(_ angularGradient: AngularGradientComponent) -> Result {
        return defaultVisit(angularGradient)
    }
    
    mutating func visitRadialGradient(_ radialGradient: RadialGradientComponent) -> Result {
        return defaultVisit(radialGradient)
    }
    
    mutating func visitEllipticalGradient(_ ellipticalGradient: EllipticalGradientComponent) -> Result {
        return defaultVisit(ellipticalGradient)
    }
    
    // Shape Components Default Implementations
    mutating func visitCircle(_ circle: CircleComponent) -> Result {
        return defaultVisit(circle)
    }
    
    mutating func visitEllipse(_ ellipse: EllipseComponent) -> Result {
        return defaultVisit(ellipse)
    }
    
    mutating func visitRectangle(_ rectangle: RectangleComponent) -> Result {
        return defaultVisit(rectangle)
    }
    
    mutating func visitRoundedRectangle(_ roundedRectangle: RoundedRectangleComponent) -> Result {
        return defaultVisit(roundedRectangle)
    }
    
    mutating func visitCapsule(_ capsule: CapsuleComponent) -> Result {
        return defaultVisit(capsule)
    }
    
    // Modifier Components Default Implementations
    mutating func visitAccessibilityHidden(_ accessibilityHidden: AccessibilityHiddenComponent) -> Result {
        return defaultVisit(accessibilityHidden)
    }
    
    mutating func visitAccessibilityHint(_ accessibilityHint: AccessibilityHintComponent) -> Result {
        return defaultVisit(accessibilityHint)
    }
    
    mutating func visitAccessibilityLabel(_ accessibilityLabel: AccessibilityLabelComponent) -> Result {
        return defaultVisit(accessibilityLabel)
    }
    
    mutating func visitAccessibilityRepresentation(_ accessibilityRepresentation: AccessibilityRepresentationComponent) -> Result {
        return defaultVisit(accessibilityRepresentation)
    }
    
    mutating func visitAccessibilityValue(_ accessibilityValue: AccessibilityValueComponent) -> Result {
        return defaultVisit(accessibilityValue)
    }
    
    mutating func visitAccessibilityAddTraits(_ accessibilityAddTraits: AccessibilityAddTraitsComponent) -> Result {
        return defaultVisit(accessibilityAddTraits)
    }
    
    mutating func visitAccessibilityRemoveTraits(_ accessibilityRemoveTraits: AccessibilityRemoveTraitsComponent) -> Result {
        return defaultVisit(accessibilityRemoveTraits)
    }
    
    mutating func visitAllowsHitTesting(_ allowsHitTesting: AllowsHitTestingComponent) -> Result {
        return defaultVisit(allowsHitTesting)
    }
    
    mutating func visitAllowsTightening(_ allowsTightening: AllowsTighteningComponent) -> Result {
        return defaultVisit(allowsTightening)
    }
    
    mutating func visitAspectRatio(_ aspectRatio: AspectRatioComponent) -> Result {
        return defaultVisit(aspectRatio)
    }
    
    mutating func visitBackground(_ background: BackgroundComponent) -> Result {
        return defaultVisit(background)
    }
    
    mutating func visitBlendMode(_ blendMode: BlendModeComponent) -> Result {
        return defaultVisit(blendMode)
    }
    
    mutating func visitBlur(_ blur: BlurComponent) -> Result {
        return defaultVisit(blur)
    }
    
    mutating func visitBold(_ bold: BoldComponent) -> Result {
        return defaultVisit(bold)
    }
    
    mutating func visitBorder(_ border: BorderComponent) -> Result {
        return defaultVisit(border)
    }
    
    mutating func visitBrightness(_ brightness: BrightnessComponent) -> Result {
        return defaultVisit(brightness)
    }
    
    mutating func visitClipped(_ clipped: ClippedComponent) -> Result {
        return defaultVisit(clipped)
    }
    
    mutating func visitClipShape(_ clipShape: ClipShapeComponent) -> Result {
        return defaultVisit(clipShape)
    }
    
    mutating func visitColorInvert(_ colorInvert: ColorInvertComponent) -> Result {
        return defaultVisit(colorInvert)
    }
    
    mutating func visitColorScheme(_ colorScheme: ColorSchemeComponent) -> Result {
        return defaultVisit(colorScheme)
    }
    
    mutating func visitContentShape(_ contentShape: ContentShapeComponent) -> Result {
        return defaultVisit(contentShape)
    }
    
    mutating func visitContrast(_ contrast: ContrastComponent) -> Result {
        return defaultVisit(contrast)
    }
    
    mutating func visitControlSize(_ controlSize: ControlSizeComponent) -> Result {
        return defaultVisit(controlSize)
    }
    
    mutating func visitCornerRadius(_ cornerRadius: CornerRadiusComponent) -> Result {
        return defaultVisit(cornerRadius)
    }
    
    mutating func visitCoordinateSpace(_ coordinateSpace: CoordinateSpaceComponent) -> Result {
        return defaultVisit(coordinateSpace)
    }
    
    mutating func visitDisabled(_ disabled: DisabledComponent) -> Result {
        return defaultVisit(disabled)
    }
    
    mutating func visitAutocorrectionDisabled(_ autocorrectionDisabled: AutocorrectionDisabledComponent) -> Result {
        return defaultVisit(autocorrectionDisabled)
    }
    
    mutating func visitDynamicTypeSize(_ dynamicTypeSize: DynamicTypeSizeComponent) -> Result {
        return defaultVisit(dynamicTypeSize)
    }
    
    mutating func visitFixedSize(_ fixedSize: FixedSizeComponent) -> Result {
        return defaultVisit(fixedSize)
    }
    
    mutating func visitFlexibleFrame(_ flexibleFrame: FlexibleFrameComponent) -> Result {
        return defaultVisit(flexibleFrame)
    }
    
    mutating func visitFont(_ font: FontComponent) -> Result {
        return defaultVisit(font)
    }
    
    mutating func visitFontCustom(_ fontCustom: FontCustomComponent) -> Result {
        return defaultVisit(fontCustom)
    }
    
    mutating func visitFontDesign(_ fontDesign: FontDesignComponent) -> Result {
        return defaultVisit(fontDesign)
    }
    
    mutating func visitFontWeight(_ fontWeight: FontWeightComponent) -> Result {
        return defaultVisit(fontWeight)
    }
    
    mutating func visitFontWidth(_ fontWidth: FontWidthComponent) -> Result {
        return defaultVisit(fontWidth)
    }
    
    mutating func visitForegroundStyle(_ foregroundStyle: ForegroundStyleComponent) -> Result {
        return defaultVisit(foregroundStyle)
    }
    
    mutating func visitFrame(_ frame: FrameComponent) -> Result {
        return defaultVisit(frame)
    }
    
    mutating func visitPickerStyle(_ pickerStyle: PickerStyleComponent) -> Result {
        return defaultVisit(pickerStyle)
    }

    mutating func visitGlassEffect(_ glassEffect: GlassEffectComponent) -> Result {
        return defaultVisit(glassEffect)
    }
    
    mutating func visitGrayscale(_ grayscale: GrayscaleComponent) -> Result {
        return defaultVisit(grayscale)
    }
    
    mutating func visitHidden(_ hidden: HiddenComponent) -> Result {
        return defaultVisit(hidden)
    }
    
    mutating func visitID(_ id: IDComponent) -> Result {
        return defaultVisit(id)
    }
    
    mutating func visitIgnoresSafeArea(_ ignoresSafeArea: IgnoresSafeAreaComponent) -> Result {
        return defaultVisit(ignoresSafeArea)
    }
    
    mutating func visitItalic(_ italic: ItalicComponent) -> Result {
        return defaultVisit(italic)
    }
    
    mutating func visitLayoutPriority(_ layoutPriority: LayoutPriorityComponent) -> Result {
        return defaultVisit(layoutPriority)
    }
    
    mutating func visitLineLimit(_ lineLimit: LineLimitComponent) -> Result {
        return defaultVisit(lineLimit)
    }
    
    mutating func visitLineSpacing(_ lineSpacing: LineSpacingComponent) -> Result {
        return defaultVisit(lineSpacing)
    }

    mutating func visitMask(_ mask: MaskComponent) -> Result {
        return defaultVisit(mask)
    }

    mutating func visitMinimumScaleFactor(_ minimumScaleFactor: MinimumScaleFactorComponent) -> Result {
        return defaultVisit(minimumScaleFactor)
    }
    
    mutating func visitMonospaced(_ monospaced: MonospacedComponent) -> Result {
        return defaultVisit(monospaced)
    }
    
    mutating func visitMultilineTextAlignment(_ multilineTextAlignment: MultilineTextAlignmentComponent) -> Result {
        return defaultVisit(multilineTextAlignment)
    }
    
    mutating func visitNavigationTitle(_ navigationTitle: NavigationTitleComponent) -> Result {
        return defaultVisit(navigationTitle)
    }
    
    mutating func visitOffset(_ offset: OffsetComponent) -> Result {
        return defaultVisit(offset)
    }
    
    mutating func visitOnAppear(_ onAppear: OnAppearComponent) -> Result {
        return defaultVisit(onAppear)
    }
    
    mutating func visitOnDisappear(_ onDisappear: OnDisappearComponent) -> Result {
        return defaultVisit(onDisappear)
    }
    
    mutating func visitOnDragGesture(_ onDragGesture: OnDragGestureComponent) -> Result {
        return defaultVisit(onDragGesture)
    }
    
    mutating func visitOnLongPressGesture(_ onLongPressGesture: OnLongPressGestureComponent) -> Result {
        return defaultVisit(onLongPressGesture)
    }
    
    mutating func visitOnTapGesture(_ onTapGesture: OnTapGestureComponent) -> Result {
        return defaultVisit(onTapGesture)
    }
    
    mutating func visitOpacity(_ opacity: OpacityComponent) -> Result {
        return defaultVisit(opacity)
    }
    
    mutating func visitOverlay(_ overlay: OverlayComponent) -> Result {
        return defaultVisit(overlay)
    }
    
    mutating func visitPadding(_ padding: PaddingComponent) -> Result {
        return defaultVisit(padding)
    }
    
    mutating func visitRotationEffect(_ rotationEffect: RotationEffectComponent) -> Result {
        return defaultVisit(rotationEffect)
    }
    
    mutating func visitSaturation(_ saturation: SaturationComponent) -> Result {
        return defaultVisit(saturation)
    }
    
    mutating func visitScaleEffect(_ scaleEffect: ScaleEffectComponent) -> Result {
        return defaultVisit(scaleEffect)
    }
    
    mutating func visitScaledToFill(_ scaledToFill: ScaledToFillComponent) -> Result {
        return defaultVisit(scaledToFill)
    }
    
    mutating func visitScaledToFit(_ scaledToFit: ScaledToFitComponent) -> Result {
        return defaultVisit(scaledToFit)
    }
    
    mutating func visitShadow(_ shadow: ShadowComponent) -> Result {
        return defaultVisit(shadow)
    }
    
    mutating func visitStrikethrough(_ strikethrough: StrikethroughComponent) -> Result {
        return defaultVisit(strikethrough)
    }
    
    mutating func visitTag(_ tag: TagComponent) -> Result {
        return defaultVisit(tag)
    }
    
    mutating func visitTextCase(_ textCase: TextCaseComponent) -> Result {
        return defaultVisit(textCase)
    }
    
    mutating func visitTextSelection(_ textSelection: TextSelectionComponent) -> Result {
        return defaultVisit(textSelection)
    }
    
    mutating func visitTint(_ tint: TintComponent) -> Result {
        return defaultVisit(tint)
    }
    
    mutating func visitTracking(_ tracking: TrackingComponent) -> Result {
        return defaultVisit(tracking)
    }
    
    mutating func visitTransformEffect(_ transformEffect: TransformEffectComponent) -> Result {
        return defaultVisit(transformEffect)
    }
    
    mutating func visitUnderline(_ underline: UnderlineComponent) -> Result {
        return defaultVisit(underline)
    }
    
    mutating func visitVisualEffect(_ visualEffect: VisualEffectComponent) -> Result {
        return defaultVisit(visualEffect)
    }
    
    mutating func visitZIndex(_ zIndex: ZIndexComponent) -> Result {
        return defaultVisit(zIndex)
    }
}
