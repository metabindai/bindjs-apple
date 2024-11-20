protocol ComponentConvertible: AST {
    init(_ component: Component)
    var component: Component { get }
}

extension ComponentConvertible {
    public func accept<V>(_ visitor: inout V) -> V.Result where V: ASTVisitor {
        component.accept(&visitor)
    }
}

extension ComponentConvertible {
    static var componentName: String {
        String(describing: Self.self).replacingOccurrences(of: "Convertible", with: "").lowercased()
    }
}

func convertComponent(_ component: Component) -> ComponentConvertible? {
    switch component.type.lowercased() {
    case AccessibilityLabelConvertible.componentName: AccessibilityLabelConvertible(component)
    case AspectRatioConvertible.componentName: AspectRatioConvertible(component)
    case BackgroundConvertible.componentName: BackgroundConvertible(component)
    case BlendModeConvertible.componentName: BlendModeConvertible(component)
    case BlurConvertible.componentName: BlurConvertible(component)
    case BoldConvertible.componentName: BoldConvertible(component)
    case BorderConvertible.componentName: BorderConvertible(component)
    case ButtonConvertible.componentName: ButtonConvertible(component)
    case ButtonStyleConvertible.componentName: ButtonStyleConvertible(component)
    case CapsuleConvertible.componentName: CapsuleConvertible(component)
    case CircleConvertible.componentName: CircleConvertible(component)
    case ColorConvertible.componentName: ColorConvertible(component)
    case CompositingGroupConvertible.componentName: CompositingGroupConvertible(component)
    case CornerRadiusConvertible.componentName: CornerRadiusConvertible(component)
    case DisabledConvertible.componentName: DisabledConvertible(component)
    case DividerConvertible.componentName: DividerConvertible(component)
    case DrawingGroupConvertible.componentName: DrawingGroupConvertible(component)
    case EllipseConvertible.componentName: EllipseConvertible(component)
    case FontConvertible.componentName: FontConvertible(component)
    case FontConvertible.fontSizeName: FontConvertible(component)
    case FontDesignConvertible.componentName: FontDesignConvertible(component)
    case FontWeightConvertible.componentName: FontWeightConvertible(component)
    case ForegroundStyleConvertible.componentName: ForegroundStyleConvertible(component)
    case FrameConvertible.componentName:
        if Set(component.props.keys).isDisjoint(with: FlexFrameConvertible.keys) {
            FrameConvertible(component)
        } else {
            FlexFrameConvertible(component)
        }
    case HiddenConvertible.componentName: HiddenConvertible(component)
    case HStackConvertible.componentName: HStackConvertible(component)
    case IgnoresSafeAreaConvertible.componentName: IgnoresSafeAreaConvertible(component)
    case ImageConvertible.componentName: ImageConvertible(component)
    case ItalicConvertible.componentName: ItalicConvertible(component)
    case KerningConvertible.componentName: KerningConvertible(component)
    case LabelConvertible.componentName: LabelConvertible(component)
    case LabelStyleConvertible.componentName: LabelStyleConvertible(component)
    case LazyHStackConvertible.componentName: LazyHStackConvertible(component)
    case LazyVStackConvertible.componentName: LazyVStackConvertible(component)
    case LinearGradientConvertible.componentName: LinearGradientConvertible(component)
    case LineLimitConvertible.componentName: LineLimitConvertible(component)
    case ListConvertible.componentName: ListConvertible(component)
    case MaskConvertible.componentName: MaskConvertible(component)
    case MaterialConvertible.componentName: MaterialConvertible(component)
    case MultilineTextAlignmentConvertible.componentName: MultilineTextAlignmentConvertible(component)
    case OffsetConvertible.componentName: OffsetConvertible(component)
    case OnTapConvertible.componentName: OnTapConvertible(component)
    case OpacityConvertible.componentName: OpacityConvertible(component)
    case OverlayConvertible.componentName: OverlayConvertible(component)
    case PaddingConvertible.componentName: PaddingConvertible(component)
    case PolygonConvertible.componentName: PolygonConvertible(component)
    case PositionConvertible.componentName: PositionConvertible(component)
    case ProgressViewConvertible.componentName: ProgressViewConvertible(component)
    case ProgressViewStyleConvertible.componentName: ProgressViewStyleConvertible(component)
    case RectangleConvertible.componentName: RectangleConvertible(component)
    case RectangleConvertible.roundedRectangleName: RectangleConvertible(component)
    case RotationEffectConvertible.componentName: RotationEffectConvertible(component)
    case ScaledToFillConvertible.componentName: ScaledToFillConvertible(component)
    case ScaledToFitConvertible.componentName: ScaledToFitConvertible(component)
    case ScaleEffectConvertible.componentName: ScaleEffectConvertible(component)
    case ScrollViewConvertible.componentName: ScrollViewConvertible(component)
    case ShadowConvertible.componentName: ShadowConvertible(component)
    case SpacerConvertible.componentName: SpacerConvertible(component)
    case TextConvertible.componentName: TextConvertible(component)
    case ToggleConvertible.componentName: ToggleConvertible(component)
    case ToggleStyleConvertible.componentName: ToggleStyleConvertible(component)
    case TriangleConvertible.componentName: TriangleConvertible(component)
    case TrackingConvertible.componentName: TrackingConvertible(component)
    case VStackConvertible.componentName: VStackConvertible(component)
    case ZIndexConvertible.componentName: ZIndexConvertible(component)
    case ZStackConvertible.componentName: ZStackConvertible(component)
    default: nil
    }
}
