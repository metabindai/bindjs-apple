public protocol ComponentWalker: ComponentVisitor where Result == Void {
    
}

public extension ComponentWalker {
    mutating func descendInto(_ component: Component) {
        let mirror = Mirror(reflecting: component)
        for child in mirror.children {
            if let component = child.value as? Component {
                visit(component)
            } else if let components = child.value as? [Component] {
                for component in components {
                    visit(component)
                }
            } else if let optionalComponent = child.value as? Optional<Component>,
                      let component = optionalComponent {
                visit(component)
            }
        }
    }
    
    // Views Components
    mutating func visitButton(_ button: ButtonComponent) {
        descendInto(button)
    }
    mutating func visitCall(_ call: CallComponent) {
        descendInto(call)
    }
    mutating func visitColor(_ color: ColorComponent) {
        descendInto(color)
    }
    mutating func visitDivider(_ divider: DividerComponent) {
        descendInto(divider)
    }
    mutating func visitForEach(_ forEach: ForEachComponent) {
        descendInto(forEach)
    }
    mutating func visitGroup(_ group: GroupComponent) {
        descendInto(group)
    }
    mutating func visitHStack(_ hStack: HStackComponent) {
        descendInto(hStack)
    }
    mutating func visitImage(_ image: ImageComponent) {
        descendInto(image)
    }
    mutating func visitMaterial(_ material: MaterialComponent) {
        descendInto(material)
    }
    mutating func visitModified(_ modified: ModifiedComponent) {
        descendInto(modified)
    }
    mutating func visitEmpty(_ empty: EmptyComponent) {
        descendInto(empty)
    }
    mutating func visitProgressView(_ progressView: ProgressViewComponent) {
        descendInto(progressView)
    }
    mutating func visitScrollView(_ scrollView: ScrollViewComponent) {
        descendInto(scrollView)
    }
    mutating func visitSection(_ section: SectionComponent) {
        descendInto(section)
    }
    mutating func visitSpacer(_ spacer: SpacerComponent) {
        descendInto(spacer)
    }
    mutating func visitText(_ text: TextComponent) {
        descendInto(text)
    }
    mutating func visitUnresolved(_ unresolved: UnresolvedComponent) {
        descendInto(unresolved)
    }
    mutating func visitVStack(_ vStack: VStackComponent) {
        descendInto(vStack)
    }
    mutating func visitVideo(_ video: VideoComponent) {
        descendInto(video)
    }
    mutating func visitZStack(_ zStack: ZStackComponent) {
        descendInto(zStack)
    }
    
    // Gradient Components
    mutating func visitLinearGradient(_ linearGradient: LinearGradientComponent) {
        descendInto(linearGradient)
    }
    mutating func visitAngularGradient(_ angularGradient: AngularGradientComponent) {
        descendInto(angularGradient)
    }
    mutating func visitRadialGradient(_ radialGradient: RadialGradientComponent) {
        descendInto(radialGradient)
    }
    mutating func visitEllipticalGradient(_ ellipticalGradient: EllipticalGradientComponent) {
        descendInto(ellipticalGradient)
    }
    
    // Shape Components
    mutating func visitCircle(_ circle: CircleComponent) {
        descendInto(circle)
    }
    mutating func visitEllipse(_ ellipse: EllipseComponent) {
        descendInto(ellipse)
    }
    mutating func visitRectangle(_ rectangle: RectangleComponent) {
        descendInto(rectangle)
    }
    mutating func visitRoundedRectangle(_ roundedRectangle: RoundedRectangleComponent) {
        descendInto(roundedRectangle)
    }
    mutating func visitCapsule(_ capsule: CapsuleComponent) {
        descendInto(capsule)
    }
    
    // Modifier Components
    mutating func visitAccessibilityHidden(_ accessibilityHidden: AccessibilityHiddenComponent) {
        descendInto(accessibilityHidden)
    }
    mutating func visitAccessibilityHint(_ accessibilityHint: AccessibilityHintComponent) {
        descendInto(accessibilityHint)
    }
    mutating func visitAccessibilityLabel(_ accessibilityLabel: AccessibilityLabelComponent) {
        descendInto(accessibilityLabel)
    }
    mutating func visitAccessibilityRepresentation(_ accessibilityRepresentation: AccessibilityRepresentationComponent) {
        descendInto(accessibilityRepresentation)
    }
    mutating func visitAllowsHitTesting(_ allowsHitTesting: AllowsHitTestingComponent) {
        descendInto(allowsHitTesting)
    }
    mutating func visitAspectRatio(_ aspectRatio: AspectRatioComponent) {
        descendInto(aspectRatio)
    }
    mutating func visitBackground(_ background: BackgroundComponent) {
        descendInto(background)
    }
    mutating func visitBlendMode(_ blendMode: BlendModeComponent) {
        descendInto(blendMode)
    }
    mutating func visitBlur(_ blur: BlurComponent) {
        descendInto(blur)
    }
    mutating func visitBold(_ bold: BoldComponent) {
        descendInto(bold)
    }
    mutating func visitBorder(_ border: BorderComponent) {
        descendInto(border)
    }
    mutating func visitBrightness(_ brightness: BrightnessComponent) {
        descendInto(brightness)
    }
    mutating func visitClipped(_ clipped: ClippedComponent) {
        descendInto(clipped)
    }
    mutating func visitColorInvert(_ colorInvert: ColorInvertComponent) {
        descendInto(colorInvert)
    }
    mutating func visitColorScheme(_ colorScheme: ColorSchemeComponent) {
        descendInto(colorScheme)
    }
    mutating func visitContentShape(_ contentShape: ContentShapeComponent) {
        descendInto(contentShape)
    }
    mutating func visitContrast(_ contrast: ContrastComponent) {
        descendInto(contrast)
    }
    mutating func visitControlSize(_ controlSize: ControlSizeComponent) {
        descendInto(controlSize)
    }
    mutating func visitCornerRadius(_ cornerRadius: CornerRadiusComponent) {
        descendInto(cornerRadius)
    }
    mutating func visitDisabled(_ disabled: DisabledComponent) {
        descendInto(disabled)
    }
    mutating func visitDynamicTypeSize(_ dynamicTypeSize: DynamicTypeSizeComponent) {
        descendInto(dynamicTypeSize)
    }
    mutating func visitFlexibleFrame(_ flexibleFrame: FlexibleFrameComponent) {
        descendInto(flexibleFrame)
    }
    mutating func visitFont(_ font: FontComponent) {
        descendInto(font)
    }
    mutating func visitFontCustom(_ fontCustom: FontCustomComponent) {
        descendInto(fontCustom)
    }
    mutating func visitFontDesign(_ fontDesign: FontDesignComponent) {
        descendInto(fontDesign)
    }
    mutating func visitFontWeight(_ fontWeight: FontWeightComponent) {
        descendInto(fontWeight)
    }
    mutating func visitFontWidth(_ fontWidth: FontWidthComponent) {
        descendInto(fontWidth)
    }
    mutating func visitForegroundStyle(_ foregroundStyle: ForegroundStyleComponent) {
        descendInto(foregroundStyle)
    }
    mutating func visitFrame(_ frame: FrameComponent) {
        descendInto(frame)
    }
    mutating func visitGrayscale(_ grayscale: GrayscaleComponent) {
        descendInto(grayscale)
    }
    mutating func visitHidden(_ hidden: HiddenComponent) {
        descendInto(hidden)
    }
    mutating func visitID(_ id: IDComponent) {
        descendInto(id)
    }
    mutating func visitIgnoresSafeArea(_ ignoresSafeArea: IgnoresSafeAreaComponent) {
        descendInto(ignoresSafeArea)
    }
    mutating func visitItalic(_ italic: ItalicComponent) {
        descendInto(italic)
    }
    mutating func visitLineLimit(_ lineLimit: LineLimitComponent) {
        descendInto(lineLimit)
    }
    mutating func visitLineSpacing(_ lineSpacing: LineSpacingComponent) {
        descendInto(lineSpacing)
    }
    mutating func visitMonospaced(_ monospaced: MonospacedComponent) {
        descendInto(monospaced)
    }
    mutating func visitMultilineTextAlignment(_ multilineTextAlignment: MultilineTextAlignmentComponent) {
        descendInto(multilineTextAlignment)
    }
    mutating func visitNavigationTitle(_ navigationTitle: NavigationTitleComponent) {
        descendInto(navigationTitle)
    }
    mutating func visitOffset(_ offset: OffsetComponent) {
        descendInto(offset)
    }
    mutating func visitOnAppear(_ onAppear: OnAppearComponent) {
        descendInto(onAppear)
    }
    mutating func visitOnDisappear(_ onDisappear: OnDisappearComponent) {
        descendInto(onDisappear)
    }
    mutating func visitOnDragGesture(_ onDragGesture: OnDragGestureComponent) {
        descendInto(onDragGesture)
    }
    mutating func visitOnLongPressGesture(_ onLongPressGesture: OnLongPressGestureComponent) {
        descendInto(onLongPressGesture)
    }
    mutating func visitOnTapGesture(_ onTapGesture: OnTapGestureComponent) {
        descendInto(onTapGesture)
    }
    mutating func visitOpacity(_ opacity: OpacityComponent) {
        descendInto(opacity)
    }
    mutating func visitOverlay(_ overlay: OverlayComponent) {
        descendInto(overlay)
    }
    mutating func visitPadding(_ padding: PaddingComponent) {
        descendInto(padding)
    }
    mutating func visitRotationEffect(_ rotationEffect: RotationEffectComponent) {
        descendInto(rotationEffect)
    }
    mutating func visitSaturation(_ saturation: SaturationComponent) {
        descendInto(saturation)
    }
    mutating func visitScaleEffect(_ scaleEffect: ScaleEffectComponent) {
        descendInto(scaleEffect)
    }
    mutating func visitScaledToFill(_ scaledToFill: ScaledToFillComponent) {
        descendInto(scaledToFill)
    }
    mutating func visitScaledToFit(_ scaledToFit: ScaledToFitComponent) {
        descendInto(scaledToFit)
    }
    mutating func visitShadow(_ shadow: ShadowComponent) {
        descendInto(shadow)
    }
    mutating func visitStrikethrough(_ strikethrough: StrikethroughComponent) {
        descendInto(strikethrough)
    }
    mutating func visitTextCase(_ textCase: TextCaseComponent) {
        descendInto(textCase)
    }
    mutating func visitTextSelection(_ textSelection: TextSelectionComponent) {
        descendInto(textSelection)
    }
    mutating func visitTracking(_ tracking: TrackingComponent) {
        descendInto(tracking)
    }
    mutating func visitTransformEffect(_ transformEffect: TransformEffectComponent) {
        descendInto(transformEffect)
    }
    mutating func visitUnderline(_ underline: UnderlineComponent) {
        descendInto(underline)
    }
    mutating func visitZIndex(_ zIndex: ZIndexComponent) {
        descendInto(zIndex)
    }
}
