public extension ComponentProtocol {
    func modifier(_ m: ComponentProtocol) -> ComponentProtocol {
        ModifiedComponent(content: self, modifier: m)
    }
    
    func defaults(_ key: String, _ value: ComponentProtocol) -> ComponentProtocol {
        Defaults(constants: [key: value], content: self)
    }
    
    func registration(_ component: Component) -> ComponentProtocol {
        Defaults(constants: [component.type: Closure(props: component.props, body: component.children)], content: self)
    }
    
    func background(_ content: ComponentProtocol) -> ComponentProtocol {
        modifier(BackgroundComponent(content: content))
    }
    
    func buttonStyle(_ style: ButtonStyleComponent) -> ComponentProtocol {
        modifier(style)
    }
    
    func buttonStyle(_ named: String) -> ComponentProtocol {
        modifier(ButtonStyleComponent.custom(named))
    }
    
    func overlay(_ content: ComponentProtocol) -> ComponentProtocol {
        modifier(OverlayComponent(content: content))
    }
    
    func mask(_ content: ComponentProtocol) -> ComponentProtocol {
        modifier(MaskComponent(content: content))
    }
    
    func frame(width: Double? = nil, height: Double? = nil, alignment: AlignmentComponent = .init()) -> ComponentProtocol {
        modifier(FrameComponent(width: width, height: height, alignment: alignment))
    }
    
    func flexFrame(minWidth: Double? = nil, idealWidth: Double? = nil, maxWidth: Double? = nil,
                   minHeight: Double? = nil, idealHeight: Double? = nil, maxHeight: Double? = nil,
                   alignment: AlignmentComponent = .init()) -> ComponentProtocol {
        modifier(FlexFrameComponent(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth,
                                    minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight,
                                    alignment: alignment))
    }
    
    func padding(_ edges: EdgeSetComponent = .all, _ length: Double? = nil) -> ComponentProtocol {
        let insets = length.map { EdgeInsetsComponent.all($0) }
        return modifier(PaddingComponent(edges: edges, insets: insets))
    }
    
    func padding(_ length: Double) -> ComponentProtocol {
        padding(.all, length)
    }
    
    func aspectRatio(_ ratio: Double? = nil, contentMode: ContentModeComponent = .fit) -> ComponentProtocol {
        modifier(AspectRatioComponent(aspectRatio: ratio ?? 1.0, contentMode: contentMode))
    }
    
    func scaledToFit() -> ComponentProtocol {
        modifier(ScaledToFitComponent())
    }
    
    func scaledToFill() -> ComponentProtocol {
        modifier(ScaledToFillComponent())
    }
    
    func position(x: Double = 0.0, y: Double = 0.0) -> ComponentProtocol {
        modifier(PositionComponent(x: x, y: y))
    }
    
    func zIndex(_ index: Double) -> ComponentProtocol {
        modifier(ZIndexComponent(value: index))
    }
    
    func hidden(_ isHidden: Bool = true) -> ComponentProtocol {
        modifier(HiddenComponent(isActive: isHidden))
    }
    
    func font(_ size: Double) -> ComponentProtocol {
        modifier(FontSizeComponent(size: size))
    }
    
    func font(_ style: FontStyleComponent) -> ComponentProtocol {
        modifier(style)
    }
    
    func fontWeight(_ weight: FontWeightComponent) -> ComponentProtocol {
        modifier(weight)
    }
    
    func fontDesign(_ design: FontDesignComponent) -> ComponentProtocol {
        modifier(design)
    }
    
    func kerning(_ kerning: Double) -> ComponentProtocol {
        modifier(KerningComponent(value: kerning))
    }
    
    func tracking(_ tracking: Double) -> ComponentProtocol {
        modifier(TrackingComponent(value: tracking))
    }
    
    func bold() -> ComponentProtocol {
        modifier(BoldComponent())
    }
    
    func italic() -> ComponentProtocol {
        modifier(ItalicComponent())
    }
    
    func multilineTextAlignment(_ alignment: HorizontalAlignmentComponent) -> ComponentProtocol {
        modifier(MultiLineTextAlignmentComponent(alignment: alignment))
    }
    
    func lineLimit(_ limit: Int) -> ComponentProtocol {
        modifier(LineLimitComponent(value: limit))
    }
    
    func scaleEffect(x: Double = 1.0, y: Double = 1.0, anchor: UnitPointComponent = .center) -> ComponentProtocol {
        modifier(ScaleEffectComponent(x: x, y: y, anchor: anchor))
    }
    
    func rotationEffect(_ angle: Double, anchor: UnitPointComponent = .center) -> ComponentProtocol {
        modifier(RotationEffectComponent(angle: angle, anchor: anchor))
    }
    
    func offset(x: Double = 0.0, y: Double = 0.0) -> ComponentProtocol {
        modifier(OffsetComponent(x: x, y: y))
    }
    
    func shadow(color: ColorComponent = .init(opacity: 0.5), radius: Double = 10.0, x: Double = 0.0, y: Double = 5.0) -> ComponentProtocol {
        modifier(ShadowComponent(color: color, radius: radius, x: x, y: y))
    }
    
    func border(_ color: ColorComponent, width: Double = 1.0) -> ComponentProtocol {
        modifier(BorderComponent(color: color, width: width))
    }
    
    func border(_ gradient: LinearGradientComponent, width: Double = 1.0) -> ComponentProtocol {
        modifier(BorderComponent(gradient: gradient, width: width))
    }
    
    func blur(radius: Double) -> ComponentProtocol {
        modifier(BlurComponent(radius: radius))
    }
    
    func opacity(_ opacity: Double) -> ComponentProtocol {
        modifier(OpacityComponent(value: opacity))
    }
    
    func cornerRadius(_ radius: Double) -> ComponentProtocol {
        modifier(CornerRadiusComponent(radius: radius))
    }
    
    func ignoresSafeArea(_ edges: Bool = true) -> ComponentProtocol {
        modifier(IgnoresSafeAreaComponent(isActive: edges))
    }
    
    func disabled(_ disabled: Bool = true) -> ComponentProtocol {
        modifier(DisabledComponent(isActive: disabled))
    }
    
    func compositingGroup() -> ComponentProtocol {
        modifier(CompositingGroupComponent())
    }
    
    func foregroundStyle(_ color: ColorComponent) -> ComponentProtocol {
        modifier(ForegroundStyleComponent(color: color))
    }
    
    func foregroundStyle(_ gradient: LinearGradientComponent) -> ComponentProtocol {
        modifier(ForegroundStyleComponent(gradient: gradient))
    }
    
    func foregroundStyle(_ material: MaterialComponent) -> ComponentProtocol {
        modifier(ForegroundStyleComponent(material: material))
    }
    
    func foregroundStyle(_ name: String) -> ComponentProtocol {
        modifier(ForegroundStyleComponent(name: name))
    }
    
    func accessibilityLabel(_ label: String) -> ComponentProtocol {
        modifier(AccessibilityLabelComponent(value: label))
    }
}
