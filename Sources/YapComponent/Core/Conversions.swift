import Foundation

extension ComponentProtocol {
    public var jsonString: String {
        var converter = JSONConverter()
        let result = accept(&converter)
        let data = try! JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed])
        return String(data: data, encoding: .utf8)!
    }
}

private struct JSONConverter: ComponentVisitor {
    mutating func defaultVisit(_ component: any ComponentProtocol) -> Any {
        component
    }
    
    mutating func visitEmpty(_ emptyComponent: EmptyComponent) -> Any {
        NSNull()
    }
    
    mutating func visitArray(_ array: [ComponentProtocol]) -> Any {
        array.map { $0.accept(&self) }
    }
    
    mutating func visitDictionary(_ dictionary: [String : any ComponentProtocol]) -> Any {
        dictionary.mapValues { $0.accept(&self) }
    }
    
    mutating func visitComponent(_ component: Component) -> Any {
        var result: [String: Any] = [
            "type": component.type,
        ]
        if !component.props.isEmpty {
            result["props"] = component.props.mapValues { $0.accept(&self) }
        }
        return result
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> Any {
        [
            "type": "Defaults",
            "constants": defaults.constants.mapValues { $0.accept(&self) },
            "content": defaults.content.accept(&self),
        ]
    }
    
    mutating func visitVariable(_ variable: Variable) -> Any {
        [
            "type": "Variable",
            "name": variable.name,
        ]
    }
    
    mutating func visitBinary(_ binary: Binary) -> Any {
        [
            "type": "Binary",
            "left": binary.left.accept(&self),
            "right": binary.right.accept(&self),
            "operator": binary.operator,
        ]
    }
    
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> Any {
        [
            "type": "ModifiedComponent",
            "content": modifiedComponent.content.accept(&self),
            "modifier": modifiedComponent.modifier.accept(&self),
        ]
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> Any {
        [
            "type": "ForEach",
            "data": forEach.data.accept(&self),
            "content": forEach.content.accept(&self),
        ]
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> Any {
        var result: [String: Any] = [
            "type": "Conditional",
            "condition": conditional.condition.accept(&self),
            "then": conditional.thenContent.accept(&self)
        ]
        if let elseContent = conditional.elseContent {
            result["else"] = elseContent.accept(&self)
        }
        return result
    }
    
    mutating func visitClosure(_ closure: Closure) -> Any {
        [
            "type": "Closure",
            "parameters": closure.props.mapValues { $0.accept(&self) },
            "body": closure.body.accept(&self),
        ]
    }
}

public func decodeComponent(from json: String) -> ComponentProtocol {
    let data = json.data(using: .utf8)!
    do {
        let any = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed, .json5Allowed])
        return decodeComponent(any)
    } catch {
        return EmptyComponent()
    }
}

public func decodeComponent(_ any: Any) -> ComponentProtocol {
    switch any {
    case is NSNull:
        return EmptyComponent()
    case let number as NSNumber:
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            // Check if the NSNumber represents a Bool
            return number.boolValue
        } else if Double(number.intValue) == number.doubleValue {
            // Handle as Int if it's an integer
            return number.intValue
        } else {
            // Otherwise, treat it as Double
            return number.doubleValue
        }
    case let string as String:
        return string
    case let array as [Any]:
        return array.map(decodeComponent)
    case let dictionary as [String: Any]:
        if let type = dictionary["type"] as? String {
            switch type {
            case "ModifiedComponent":
                let content = decodeComponent(dictionary["content"] ?? [:])
                let modifier = decodeComponent(dictionary["modifier"] ?? [:])
                return ModifiedComponent(content: content, modifier: modifier)
            case "Variable":
                let name = dictionary["name"] as? String ?? ""
                return Variable(name)
            case "Defaults":
                let constants = (dictionary["constants"] as? [String: Any] ?? [:]).mapValues(decodeComponent)
                let content = decodeComponent(dictionary["content"] ?? [:])
                return Defaults(constants: constants, content: content)
            case "ForEach":
                let data = decodeComponent(dictionary["data"] ?? [:])
                let content = decodeComponent(dictionary["content"] ?? [:])
                let variable = dictionary["variable"] as? String ?? ""
                return ForEachComponent(variable: variable, data: data, content: content)
            case "Conditional":
                let condition = decodeComponent(dictionary["condition"] ?? [:])
                let thenContent = decodeComponent(dictionary["then"] ?? [:])
                let elseContent = decodeComponent(dictionary["else"] ?? [:])
                return ConditionalComponent(condition: condition, thenContent: thenContent, elseContent: elseContent)
            case "Binary":
                let left = decodeComponent(dictionary["left"] ?? [:])
                let right = decodeComponent(dictionary["right"] ?? [:])
                let `operator` = dictionary["operator"] as? String ?? ""
                return Binary(left: left, operator: `operator`, right: right)
            default:
                let props = (dictionary["props"] as? [String: Any] ?? [:]).mapValues(decodeComponent)
                let component = Component(type: type, props: props)
                return convertComponent(component) ?? component
            }
        } else {
            return dictionary.mapValues(decodeComponent)
        }
    case let component as Component:
        return convertComponent(component) ?? component
    case let component as ComponentProtocol:
        return component
    default:
        return EmptyComponent()
    }
}

// MARK: Giant Switch Statement

func convertComponent(_ component: Component) -> ComponentConvertible? {
    switch component.type.lowercased() {
    case AccessibilityLabelComponent.componentName: AccessibilityLabelComponent(component)
    case AlignmentComponent.componentName: AlignmentComponent(component)
    case AspectRatioComponent.componentName: AspectRatioComponent(component)
    case AxisSetComponent.componentName: AxisSetComponent(component)
    case BackgroundComponent.componentName: BackgroundComponent(component)
    case BlurComponent.componentName: BlurComponent(component)
    case BoldComponent.componentName: BoldComponent(component)
    case BorderComponent.componentName: BorderComponent(component)
    case ButtonComponent.componentName: ButtonComponent(component)
    case ButtonStyleComponent.componentName: ButtonStyleComponent(component)
    case CapsuleComponent.componentName: CapsuleComponent(component)
    case CircleComponent.componentName: CircleComponent(component)
    case ColorComponent.componentName: ColorComponent(component)
    case CompositingGroupComponent.componentName: CompositingGroupComponent(component)
    case ContentModeComponent.componentName: ContentModeComponent(component)
    case CornerRadiusComponent.componentName: CornerRadiusComponent(component)
    case DisabledComponent.componentName: DisabledComponent(component)
    case DividerComponent.componentName: DividerComponent(component)
    case EdgeInsetsComponent.componentName: EdgeInsetsComponent(component)
    case EdgeSetComponent.componentName: EdgeSetComponent(component)
    case EllipseComponent.componentName: EllipseComponent(component)
    case FlexFrameComponent.componentName: FlexFrameComponent(component)
    case FontDesignComponent.componentName: FontDesignComponent(component)
    case FontSizeComponent.componentName: FontSizeComponent(component)
    case FontStyleComponent.componentName: FontStyleComponent(component)
    case FontWeightComponent.componentName: FontWeightComponent(component)
    case ForegroundStyleComponent.componentName: ForegroundStyleComponent(component)
    case FrameComponent.componentName: FrameComponent(component)
    case HiddenComponent.componentName: HiddenComponent(component)
    case HorizontalAlignmentComponent.componentName: HorizontalAlignmentComponent(component)
    case HStackComponent.componentName: HStackComponent(component)
    case IgnoresSafeAreaComponent.componentName: IgnoresSafeAreaComponent(component)
    case ImageComponent.componentName: ImageComponent(component)
    case ItalicComponent.componentName: ItalicComponent(component)
    case KerningComponent.componentName: KerningComponent(component)
    case LinearGradientComponent.componentName: LinearGradientComponent(component)
    case LineLimitComponent.componentName: LineLimitComponent(component)
    case ListComponent.componentName: ListComponent(component)
    case MaskComponent.componentName: MaskComponent(component)
    case MaterialComponent.componentName: MaterialComponent(component)
    case MultiLineTextAlignmentComponent.componentName: MultiLineTextAlignmentComponent(component)
    case NavigationLinkComponent.componentName: NavigationLinkComponent(component)
    case OffsetComponent.componentName: OffsetComponent(component)
    case OpacityComponent.componentName: OpacityComponent(component)
    case OverlayComponent.componentName: OverlayComponent(component)
    case PaddingComponent.componentName: PaddingComponent(component)
    case PositionComponent.componentName: PositionComponent(component)
    case ProgressComponent.componentName: ProgressComponent(component)
    case RectangleComponent.componentName: RectangleComponent(component)
    case RotationEffectComponent.componentName: RotationEffectComponent(component)
    case RoundedRectangleComponent.componentName: RoundedRectangleComponent(component)
    case ScaledToFillComponent.componentName: ScaledToFillComponent(component)
    case ScaledToFitComponent.componentName: ScaledToFitComponent(component)
    case ScaleEffectComponent.componentName: ScaleEffectComponent(component)
    case ScrollViewComponent.componentName: ScrollViewComponent(component)
    case ShadowComponent.componentName: ShadowComponent(component)
    case SpacerComponent.componentName: SpacerComponent(component)
    case TextComponent.componentName: TextComponent(component)
    case TrackingComponent.componentName: TrackingComponent(component)
    case UnitPointComponent.componentName: UnitPointComponent(component)
    case VerticalAlignmentComponent.componentName: VerticalAlignmentComponent(component)
    case VStackComponent.componentName: VStackComponent(component)
    case ZIndexComponent.componentName: ZIndexComponent(component)
    case ZStackComponent.componentName: ZStackComponent(component)
    default: nil
    }
}

// MARK: Visitors

struct CaseInViewEnum: ComponentVisitor {
    
    let context: ComponentContext
    
    mutating func defaultVisit(_ component: any ComponentProtocol) -> ComponentViewEnum? {
        return nil
    }
    
    mutating func visitDefaults(_ defaults: Defaults) -> ComponentViewEnum? {
        .defaults(defaults)
    }
    
    mutating func visitVariable(_ variable: Variable) -> ComponentViewEnum? {
        .variable(variable)
    }
    
    mutating func visitConditional(_ conditional: ConditionalComponent) -> ComponentViewEnum? {
        .conditional(conditional)
    }
    
    mutating func visitForEach(_ forEach: ForEachComponent) -> ComponentViewEnum? {
        .forEach(forEach)
    }
    
    mutating func visitString(_ string: String) -> ComponentViewEnum? {
        .string(string)
    }
    
    mutating func visitArray(_ array: [any ComponentProtocol]) -> ComponentViewEnum? {
        .array(array)
    }
    
    mutating func visitModifiedComponent(_ modifiedComponent: ModifiedComponent) -> ComponentViewEnum? {
        .modified(modifiedComponent)
    }
    
    mutating func visitClosure(_ closure: Closure) -> ComponentViewEnum? {
        nil
    }
    
    mutating func visitBinary(_ binary: Binary) -> ComponentViewEnum? {
        .binary(binary)
    }
    
    mutating func visitComponent(_ component: Component) -> ComponentViewEnum? {
        // Process the components props before switching on its type
        var component = component
        component.props = component.props.mapValues { $0.evaluate(context) }
        
        // Convert the component based on its type and return an appropriate case from the enum
        return switch component.type.lowercased() {
        case ButtonComponent.componentName: .button(ButtonComponent(component))
        case CapsuleComponent.componentName: .capsule(CapsuleComponent())
        case CircleComponent.componentName: .circle(CircleComponent())
        case ColorComponent.componentName: .color(ColorComponent(component))
        case DividerComponent.componentName: .divider(DividerComponent())
        case EllipseComponent.componentName: .ellipse(EllipseComponent())
        case HStackComponent.componentName: .hStack(HStackComponent(component))
        case ImageComponent.componentName: .image(ImageComponent(component))
        case LinearGradientComponent.componentName: .linearGradient(LinearGradientComponent(component))
        case ListComponent.componentName: .list(ListComponent(component))
        case NavigationLinkComponent.componentName: .navigationLink(NavigationLinkComponent(component))
        case ProgressComponent.componentName: .progress(ProgressComponent(component))
        case RectangleComponent.componentName: .rectangle(RectangleComponent())
        case RoundedRectangleComponent.componentName: .roundedRectangle(RoundedRectangleComponent(component))
        case ScrollViewComponent.componentName: .scrollView(ScrollViewComponent(component))
        case SpacerComponent.componentName: .spacer(SpacerComponent())
        case TextComponent.componentName: .text(TextComponent(component))
        case VStackComponent.componentName: .vStack(VStackComponent(component))
        case ZStackComponent.componentName: .zStack(ZStackComponent(component))
        default: .component(component)
        }
    }
}

struct CaseInViewModifierEnum: ComponentVisitor {
    
    let context: ComponentContext
    
    func defaultVisit(_ component: any ComponentProtocol) -> ComponentViewModifierEnum? {
        nil  // Return nil if the modifier type is not recognized
    }
    
    func visitComponent(_ component: Component) -> ComponentViewModifierEnum? {
        
        var component = component
        
        // Evaluate the props of the component
        component.props = component.props.mapValues { $0.evaluate(context) }
        
        return switch component.type.lowercased() {
        case AccessibilityLabelComponent.componentName: .accessibilityLabel(AccessibilityLabelComponent(component))
        case AspectRatioComponent.componentName: .aspectRatio(AspectRatioComponent(component))
        case BackgroundComponent.componentName: .background(BackgroundComponent(component))
        case BlurComponent.componentName: .blur(BlurComponent(component))
        case BoldComponent.componentName: .bold(BoldComponent())
        case BorderComponent.componentName: .border(BorderComponent(component))
        case ButtonStyleComponent.componentName: .buttonStyle(ButtonStyleComponent(component))
        case CompositingGroupComponent.componentName: .compositingGroup(CompositingGroupComponent())
        case CornerRadiusComponent.componentName: .cornerRadius(CornerRadiusComponent(component))
        case DisabledComponent.componentName: .disabled(DisabledComponent(component))
        case FlexFrameComponent.componentName: .flexFrame(FlexFrameComponent(component))
        case FontDesignComponent.componentName: .fontDesign(FontDesignComponent(component))
        case FontSizeComponent.componentName: .fontSize(FontSizeComponent(component))
        case FontStyleComponent.componentName: .fontStyle(FontStyleComponent(component))
        case FontWeightComponent.componentName: .fontWeight(FontWeightComponent(component))
        case ForegroundStyleComponent.componentName: .foregroundStyle(ForegroundStyleComponent(component))
        case FrameComponent.componentName: .frame(FrameComponent(component))
        case HiddenComponent.componentName: .hidden(HiddenComponent(component))
        case IgnoresSafeAreaComponent.componentName: .ignoresSafeArea(IgnoresSafeAreaComponent(component))
        case ItalicComponent.componentName: .italic(ItalicComponent())
        case KerningComponent.componentName: .kerning(KerningComponent(component))
        case LineLimitComponent.componentName: .lineLimit(LineLimitComponent(component))
        case MaskComponent.componentName: .mask(MaskComponent(component))
        case MultiLineTextAlignmentComponent.componentName: .multiLineTextAlignment(MultiLineTextAlignmentComponent(component))
        case OffsetComponent.componentName: .offset(OffsetComponent(component))
        case OpacityComponent.componentName: .opacity(OpacityComponent(component))
        case OverlayComponent.componentName: .overlay(OverlayComponent(component))
        case PaddingComponent.componentName: .padding(PaddingComponent(component))
        case PositionComponent.componentName: .position(PositionComponent(component))
        case RotationEffectComponent.componentName: .rotationEffect(RotationEffectComponent(component))
        case ScaledToFillComponent.componentName: .scaledToFill(ScaledToFillComponent())
        case ScaledToFitComponent.componentName: .scaledToFit(ScaledToFitComponent())
        case ScaleEffectComponent.componentName: .scaleEffect(ScaleEffectComponent(component))
        case ShadowComponent.componentName: .shadow(ShadowComponent(component))
        case TrackingComponent.componentName: .tracking(TrackingComponent(component))
        case ZIndexComponent.componentName: .zIndex(ZIndexComponent(component))        default: nil
        }
    }
}

extension ComponentProtocol {
    func caseInViewEnum(_ context: ComponentContext) -> ComponentViewEnum? {
        var visitor = CaseInViewEnum(context: context)
        return accept(&visitor)
    }
    
    func caseInViewModifierEnum(_ context: ComponentContext) -> ComponentViewModifierEnum? {
        var visitor = CaseInViewModifierEnum(context: context)
        return accept(&visitor)
    }
}


// MARK: - Component Protocol Extensions

