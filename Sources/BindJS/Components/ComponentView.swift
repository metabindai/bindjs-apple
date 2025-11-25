import SwiftUI

func makeComponent(_ directive: Directive) -> Component? {
    switch directive.type {
    case AngularGradientComponent.directiveName: AngularGradientComponent(from: directive)
    case ButtonComponent.directiveName: ButtonComponent(from: directive)
    case ComponentCall.directiveName: ComponentCall(from: directive)
    case CapsuleComponent.directiveName: CapsuleComponent(from: directive)
    case CircleComponent.directiveName: CircleComponent(from: directive)
    case ColorComponent.directiveName: ColorComponent(from: directive)
    case DividerComponent.directiveName: DividerComponent(from: directive)
    case EllipseComponent.directiveName: EllipseComponent(from: directive)
    case EllipticalGradientComponent.directiveName: EllipticalGradientComponent(from: directive)
    case EmptyComponent.directiveName: EmptyComponent(from: directive)
    case ForEachComponent.directiveName: ForEachComponent(from: directive)
    case GeometryReaderComponent.directiveName: GeometryReaderComponent(from: directive)
    case GroupComponent.directiveName: GroupComponent(from: directive)
    case HStackComponent.directiveName: HStackComponent(from: directive)
    case ImageComponent.directiveName: ImageComponent(from: directive)
    case LinearGradientComponent.directiveName: LinearGradientComponent(from: directive)
    case ListComponent.directiveName: ListComponent(from: directive)
    case MaterialComponent.directiveName: MaterialComponent(from: directive)
    case Model3DComponent.directiveName: Model3DComponent(from: directive)
    case ModifiedComponent.directiveName: ModifiedComponent(from: directive)
    case PickerComponent.directiveName: PickerComponent(from: directive)
    case PlaceholderComponent.directiveName: PlaceholderComponent(from: directive)
    case ProgressViewComponent.directiveName: ProgressViewComponent(from: directive)
    case RadialGradientComponent.directiveName: RadialGradientComponent(from: directive)
    case RectangleComponent.directiveName: RectangleComponent(from: directive)
    case RoundedRectangleComponent.directiveName: RoundedRectangleComponent(from: directive)
    case ScrollViewComponent.directiveName: ScrollViewComponent(from: directive)
    case SectionComponent.directiveName: SectionComponent(from: directive)
    case SecureFieldComponent.directiveName: SecureFieldComponent(from: directive)
    case SpacerComponent.directiveName: SpacerComponent(from: directive)
    case TextComponent.directiveName: TextComponent(from: directive)
    case TextEditorComponent.directiveName: TextEditorComponent(from: directive)
    case TextFieldComponent.directiveName: TextFieldComponent(from: directive)
    case ToggleComponent.directiveName: ToggleComponent(from: directive)
    case VideoComponent.directiveName: VideoComponent(from: directive)
    case VStackComponent.directiveName: VStackComponent(from: directive)
    case ZStackComponent.directiveName: ZStackComponent(from: directive)
    
    // Modifiers
        
    case AccessibilityHiddenComponent.directiveName: AccessibilityHiddenComponent(from: directive)
    case AccessibilityHintComponent.directiveName: AccessibilityHintComponent(from: directive)
    case AccessibilityLabelComponent.directiveName: AccessibilityLabelComponent(from: directive)
    case AccessibilityRepresentationComponent.directiveName: AccessibilityRepresentationComponent(from: directive)
    case AccessibilityValueComponent.directiveName: AccessibilityValueComponent(from: directive)
    case AccessibilityAddTraitsComponent.directiveName: AccessibilityAddTraitsComponent(from: directive)
    case AccessibilityRemoveTraitsComponent.directiveName: AccessibilityRemoveTraitsComponent(from: directive)
    case AllowsHitTestingComponent.directiveName: AllowsHitTestingComponent(from: directive)
    case AllowsTighteningComponent.directiveName: AllowsTighteningComponent(from: directive)
    case AspectRatioComponent.directiveName: AspectRatioComponent(from: directive)
    case AutocorrectionDisabledComponent.directiveName: AutocorrectionDisabledComponent(from: directive)
    case BackgroundComponent.directiveName: BackgroundComponent(from: directive)
    case BlendModeComponent.directiveName: BlendModeComponent(from: directive)
    case BlurComponent.directiveName: BlurComponent(from: directive)
    case BoldComponent.directiveName: BoldComponent(from: directive)
    case BorderComponent.directiveName: BorderComponent(from: directive)
    case BrightnessComponent.directiveName: BrightnessComponent(from: directive)
    case ClippedComponent.directiveName: ClippedComponent(from: directive)
    case ClipShapeComponent.directiveName: ClipShapeComponent(from: directive)
    case ColorInvertComponent.directiveName: ColorInvertComponent(from: directive)
    case ColorSchemeComponent.directiveName: ColorSchemeComponent(from: directive)
    case ContentShapeComponent.directiveName: ContentShapeComponent(from: directive)
    case ContrastComponent.directiveName: ContrastComponent(from: directive)
    case ControlSizeComponent.directiveName: ControlSizeComponent(from: directive)
    case CornerRadiusComponent.directiveName: CornerRadiusComponent(from: directive)
    case CoordinateSpaceComponent.directiveName: CoordinateSpaceComponent(from: directive)
    case DisabledComponent.directiveName: DisabledComponent(from: directive)
    case DynamicTypeSizeComponent.directiveName: DynamicTypeSizeComponent(from: directive)
    case FixedSizeComponent.directiveName: FixedSizeComponent(from: directive)
    case FocusedComponent.directiveName: FocusedComponent(from: directive)
    case FontComponent.directiveName: FontComponent(from: directive)
    case FontDesignComponent.directiveName: FontDesignComponent(from: directive)
    case FontWeightComponent.directiveName: FontWeightComponent(from: directive)
    case FontWidthComponent.directiveName: FontWidthComponent(from: directive)
    case ForegroundStyleComponent.directiveName: ForegroundStyleComponent(from: directive)
    case FrameComponent.directiveName: if Set(directive.props.keys).isDisjoint(with: ["minWidth", "minHeight", "maxWidth", "maxHeight"]) {
        FrameComponent(from: directive)
    } else {
        FlexibleFrameComponent(from: directive)
    }
    case GlassEffectComponent.directiveName: GlassEffectComponent(from: directive)
    case GrayscaleComponent.directiveName: GrayscaleComponent(from: directive)
    case HiddenComponent.directiveName: HiddenComponent(from: directive)
    case IDComponent.directiveName: IDComponent(from: directive)
    case IgnoresSafeAreaComponent.directiveName: IgnoresSafeAreaComponent(from: directive)
    case ItalicComponent.directiveName: ItalicComponent(from: directive)
    case KeyboardTypeComponent.directiveName: KeyboardTypeComponent(from: directive)
    case LayoutPriorityComponent.directiveName: LayoutPriorityComponent(from: directive)
    case LineLimitComponent.directiveName: LineLimitComponent(from: directive)
    case LineSpacingComponent.directiveName: LineSpacingComponent(from: directive)
    case MaskComponent.directiveName: MaskComponent(from: directive)
    case MinimumScaleFactorComponent.directiveName: MinimumScaleFactorComponent(from: directive)
    case MonospacedComponent.directiveName: MonospacedComponent(from: directive)
    case MultilineTextAlignmentComponent.directiveName: MultilineTextAlignmentComponent(from: directive)
    case NavigationTitleComponent.directiveName: NavigationTitleComponent(from: directive)
    case OffsetComponent.directiveName: OffsetComponent(from: directive)
    case OnAppearComponent.directiveName: OnAppearComponent(from: directive)
    case OnDisappearComponent.directiveName: OnDisappearComponent(from: directive)
    case OnDragGestureComponent.directiveName: OnDragGestureComponent(from: directive)
    case OnLongPressGestureComponent.directiveName: OnLongPressGestureComponent(from: directive)
    case OnTapGestureComponent.directiveName: OnTapGestureComponent(from: directive)
    case OnSubmitComponent.directiveName: OnSubmitComponent(from: directive)
    case OpacityComponent.directiveName: OpacityComponent(from: directive)
    case OverlayComponent.directiveName: OverlayComponent(from: directive)
    case PaddingComponent.directiveName: PaddingComponent(from: directive)
    case PickerStyleComponent.directiveName: PickerStyleComponent(from: directive)
    case PresentationDetentsComponent.directiveName: PresentationDetentsComponent(from: directive)
    case RotationEffectComponent.directiveName: RotationEffectComponent(from: directive)
    case SaturationComponent.directiveName: SaturationComponent(from: directive)
    case ScaledToFillComponent.directiveName: ScaledToFillComponent(from: directive)
    case ScaledToFitComponent.directiveName: ScaledToFitComponent(from: directive)
    case ScaleEffectComponent.directiveName: ScaleEffectComponent(from: directive)
    case ScrollContentBackgroundComponent.directiveName: ScrollContentBackgroundComponent(from: directive)
    case SubmitLabelComponent.directiveName: SubmitLabelComponent(from: directive)
    case ShadowComponent.directiveName: ShadowComponent(from: directive)
    case SheetComponent.directiveName: SheetComponent(from: directive)
    case StrikethroughComponent.directiveName: StrikethroughComponent(from: directive)
    case TagComponent.directiveName: TagComponent(from: directive)
    case TextCaseComponent.directiveName: TextCaseComponent(from: directive)
    case TextSelectionComponent.directiveName: TextSelectionComponent(from: directive)
    case TextFieldStyleComponent.directiveName: TextFieldStyleComponent(from: directive)
    case TintComponent.directiveName: TintComponent(from: directive)
    case TrackingComponent.directiveName: TrackingComponent(from: directive)
    case TransformEffectComponent.directiveName: TransformEffectComponent(from: directive)
    case UnderlineComponent.directiveName: UnderlineComponent(from: directive)
    case VisualEffectComponent.directiveName: VisualEffectComponent(from: directive)
    case ZIndexComponent.directiveName: ZIndexComponent(from: directive)
        
    // Values
        
    case FontCustomComponent.directiveName: FontCustomComponent(from: directive)
        
    default: UnresolvedComponent(from: directive)
    }
}

public struct ComponentView: View {
    let component: Component
    
    public init(_ component: Component) {
        self.component = component
    }
    
    public var body: some View {
        switch component {
        case let angularGradient as AngularGradientComponent: angularGradient
        case let button as ButtonComponent: button
        case let callComponent as ComponentCall: callComponent
        case let capsule as CapsuleComponent: capsule
        case let circle as CircleComponent: circle
        case let color as ColorComponent: color
        case let divider as DividerComponent: divider
        case let ellipse as EllipseComponent: ellipse
        case let ellipticalGradient as EllipticalGradientComponent: ellipticalGradient
        case let empty as EmptyComponent: empty
        case let forEach as ForEachComponent: forEach
        case let geometryReader as GeometryReaderComponent: geometryReader
        case let group as GroupComponent: group
        case let hStack as HStackComponent: hStack
        case let image as ImageComponent: image
        case let linearGradient as LinearGradientComponent: linearGradient
        case let list as ListComponent: list
        case let material as MaterialComponent: material
        case let model3D as Model3DComponent: model3D
        case let modified as ModifiedComponent: modified
        case let picker as PickerComponent: picker
        case let placeholder as PlaceholderComponent: placeholder
        case let progressView as ProgressViewComponent: progressView
        case let radialGradient as RadialGradientComponent: radialGradient
        case let rectangle as RectangleComponent: rectangle
        case let roundedRectangle as RoundedRectangleComponent: roundedRectangle
        case let scrollView as ScrollViewComponent: scrollView
        case let section as SectionComponent: section
        case let secureField as SecureFieldComponent: secureField
        case let spacer as SpacerComponent: spacer
        case let text as TextComponent: text
        case let textEditor as TextEditorComponent: textEditor
        case let textField as TextFieldComponent: textField
        case let toggle as ToggleComponent: toggle
        case let unresolved as UnresolvedComponent: unresolved
        case let video as VideoComponent: video
        case let vStack as VStackComponent: vStack
        case let zStack as ZStackComponent: zStack
        default: Text("Unsupported: \(type(of: component).directiveName)")
        }
    }
}

struct ComponentViewModifier: ViewModifier {
    let component: Component

    init(_ component: Component) {
        self.component = component
    }

    public func body(content: Content) -> some View {
        switch component {
        case let m as AccessibilityHiddenComponent: content.modifier(m)
        case let m as AccessibilityHintComponent: content.modifier(m)
        case let m as AccessibilityLabelComponent: content.modifier(m)
        case let m as AccessibilityRepresentationComponent: content.modifier(m)
        case let m as AccessibilityValueComponent: content.modifier(m)
        case let m as AccessibilityAddTraitsComponent: content.modifier(m)
        case let m as AccessibilityRemoveTraitsComponent: content.modifier(m)
        case let m as AllowsHitTestingComponent: content.modifier(m)
        case let m as AllowsTighteningComponent: content.modifier(m)
        case let m as AspectRatioComponent: content.modifier(m)
        case let m as AutocorrectionDisabledComponent: content.modifier(m)
        case let m as BackgroundComponent: content.modifier(m)
        case let m as BlendModeComponent: content.modifier(m)
        case let m as BlurComponent: content.modifier(m)
        case let m as BoldComponent: content.modifier(m)
        case let m as BorderComponent: content.modifier(m)
        case let m as BrightnessComponent: content.modifier(m)
        case let m as ClippedComponent: content.modifier(m)
        case let m as ClipShapeComponent: content.modifier(m)
        case let m as ColorInvertComponent: content.modifier(m)
        case let m as ColorSchemeComponent: content.modifier(m)
        case let m as ContentShapeComponent: content.modifier(m)
        case let m as ContrastComponent: content.modifier(m)
        case let m as ControlSizeComponent: content.modifier(m)
        case let m as CornerRadiusComponent: content.modifier(m)
        case let m as CoordinateSpaceComponent: content.modifier(m)
        case let m as DisabledComponent: content.modifier(m)
        case let m as DynamicTypeSizeComponent: content.modifier(m)
        case let m as FixedSizeComponent: content.modifier(m)
        case let m as FlexibleFrameComponent: content.modifier(m)
        case let m as FocusedComponent: content.modifier(m)
        case let m as FontComponent: content.modifier(m)
        case let m as FontDesignComponent: content.modifier(m)
        case let m as FontWeightComponent: content.modifier(m)
        case let m as FontWidthComponent: content.modifier(m)
        case let m as ForegroundStyleComponent: content.modifier(m)
        case let m as FrameComponent: content.modifier(m)
        case let m as GlassEffectComponent: content.modifier(m)
        case let m as GrayscaleComponent: content.modifier(m)
        case let m as HiddenComponent: content.modifier(m)
        case let m as IDComponent: content.modifier(m)
        case let m as IgnoresSafeAreaComponent: content.modifier(m)
        case let m as ItalicComponent: content.modifier(m)
        case let m as KeyboardTypeComponent: content.modifier(m)
        case let m as LayoutPriorityComponent: content.modifier(m)
        case let m as LineLimitComponent: content.modifier(m)
        case let m as LineSpacingComponent: content.modifier(m)
        case let m as MaskComponent: content.modifier(m)
        case let m as MinimumScaleFactorComponent: content.modifier(m)
        case let m as MonospacedComponent: content.modifier(m)
        case let m as MultilineTextAlignmentComponent: content.modifier(m)
        case let m as NavigationTitleComponent: content.modifier(m)
        case let m as OffsetComponent: content.modifier(m)
        case let m as OnAppearComponent: content.modifier(m)
        case let m as OnDisappearComponent: content.modifier(m)
        case let m as OnDragGestureComponent: content.modifier(m)
        case let m as OnLongPressGestureComponent: content.modifier(m)
        case let m as OnTapGestureComponent: content.modifier(m)
        case let m as OnSubmitComponent: content.modifier(m)
        case let m as OpacityComponent: content.modifier(m)
        case let m as OverlayComponent: content.modifier(m)
        case let m as PaddingComponent: content.modifier(m)
        case let m as PickerStyleComponent: content.modifier(m)
        case let m as PresentationDetentsComponent: content.modifier(m)
        case let m as RotationEffectComponent: content.modifier(m)
        case let m as SaturationComponent: content.modifier(m)
        case let m as ScaledToFillComponent: content.modifier(m)
        case let m as ScaledToFitComponent: content.modifier(m)
        case let m as ScaleEffectComponent: content.modifier(m)
        case let m as ScrollContentBackgroundComponent: content.modifier(m)
        case let m as SubmitLabelComponent: content.modifier(m)
        case let m as ShadowComponent: content.modifier(m)
        case let m as SheetComponent: content.modifier(m)
        case let m as StrikethroughComponent: content.modifier(m)
        case let m as TagComponent: content.modifier(m)
        case let m as TextCaseComponent: content.modifier(m)
        case let m as TextSelectionComponent: content.modifier(m)
        case let m as TextFieldStyleComponent: content.modifier(m)
        case let m as TintComponent: content.modifier(m)
        case let m as TrackingComponent: content.modifier(m)
        case let m as TransformEffectComponent: content.modifier(m)
        case let m as UnderlineComponent: content.modifier(m)
        case let m as VisualEffectComponent: content.modifier(m)
        case let m as ZIndexComponent: content.modifier(m)
        
        // Any other modifier
        default:
            content
        }
    }
}
