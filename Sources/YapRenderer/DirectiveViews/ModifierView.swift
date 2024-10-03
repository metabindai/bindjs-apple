import SwiftUI
import YapComponent

struct ModifierView: View {
    
    enum Name: String, CaseIterable {
        case scaleEffect
        case rotationEffect
        case offset
        case blur
        case frame
        case opacity
        case cornerRadius
        case padding
        case lineLimit
        case font
        case fontWeight
        case fontDesign
        case fontWidth
        case kerning
        case tracking
        case bold
        case italic
        case shadow
        case foregroundColor
        case foregroundStyle
        case ignoresSafeArea
        case disabled
        case scaledToFill
        case scaledToFit
        case aspectRatio
        case contentMode
        case background
        case overlay
        case mask
        case position
        case zIndex
        case hidden
        case layoutPriority
        case border
        case drawingGroup
        case compositingGroup
        case scrollClipDisabled
    }
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        switch Name(rawValue: directive.type) {
        case .layoutPriority:
            children.layoutPriority(props._0 ?? 0)
        case .hidden:
            children.hidden()
        case .zIndex:
            children.zIndex(props._0 ?? 0)
        case .position:
            children.position(x: props.x ?? 0, y: props.y ?? 0)
        case .background:
            children
                .background(ComponentView((directive.props["_0"] as? any Component) ?? EmptyComponent()))
        case .overlay:
            children
                .overlay(ComponentView((directive.props["_0"] as? any Component) ?? EmptyComponent()))
        case .mask:
            children
                .mask(ComponentView((directive.props["_0"] as? any Component) ?? EmptyComponent()))
        case .scaleEffect:
            children
                .scaleEffect(props._0 ?? 1.0, anchor: .center)
                .scaleEffect(x: props.x ?? 1.0, y: props.y ?? 1.0, anchor: .center)
        case .rotationEffect:
            children.rotationEffect(
                props.degrees.map(Angle.degrees) ??
                props.radians.map(Angle.radians) ??
                Angle.degrees(props._0 ?? 0.0)
            )
        case .offset:
            children.offset(x: props.x ?? 0, y: props.y ?? 0)
        case .blur:
            children.blur(radius: props.radius ?? props._0 ?? 0, opaque: props.opaque ?? false)
        case .frame:
            if Set(directive.props.keys).isDisjoint(with: ["minWidth", "minHeight", "idealWidth", "idealHeight", "maxWidth", "maxHeight"]) {
                children.frame(
                    width: props.width,
                    height: props.height,
                    alignment: props.alignment ?? .center
                )
            } else {
                children.frame(
                    minWidth: props.minWidth,
                    idealWidth: props.idealWidth,
                    maxWidth: props.maxWidth,
                    minHeight: props.minHeight,
                    idealHeight: props.idealHeight,
                    maxHeight: props.maxHeight,
                    alignment: props.alignment ?? .center
                )
            }
        case .opacity:
            children.opacity(props._0 ?? 1.0)
        case .cornerRadius:
            children.clipShape(RoundedRectangle(cornerRadius: props._0 ?? 0, style: .continuous))
        case .lineLimit:
            children.lineLimit(props._0 ?? nil)
        case .padding:
            if let all: Double = props._0 {
                children.padding(all)
            } else if directive.props.isEmpty {
                children.padding()
            } else {
                children.padding(
                    .init(
                        top: props.top ?? 0,
                        leading: props.leading ?? 0,
                        bottom: props.bottom ?? 0,
                        trailing: props.trailing ?? 0
                    )
                )
            }
        case .font:
            if let size: Double = props._0 {
                children.font(.system(size: size))
            } else {
                children.font(props._0 ?? .body)
            }
        case .fontWeight:
            if #available(iOS 16.0, *) {
                children.fontWeight(props._0 ?? .regular)
            } else {
                children
            }
        case .fontDesign:
            if #available(iOS 16.1, *) {
                children.fontDesign(props._0 ?? .default)
            } else {
                children
            }
        case .fontWidth:
            if #available(iOS 16.0, *) {
                children.fontWidth(props._0 ?? .standard)
            } else {
                children
            }
        case .kerning:
            if #available(iOS 16.0, *) {
                children.kerning(props._0 ?? 0)
            } else {
                children
            }
        case .tracking:
            if #available(iOS 16.0, *) {
                children.tracking(props._0 ?? 0)
            } else {
                children
            }
        case .bold:
            if #available(iOS 16.0, *) {
                children.bold(props.isActive.flatMap { $0 ?? nil } ?? true)
            } else {
                children
            }
        case .italic:
            if #available(iOS 16.0, *) {
                children.italic(props.isActive.flatMap { $0 ?? nil } ?? true)
            } else {
                children
            }
        case .shadow:
            let hasUserColor = props.directive.props.keys.contains("color")
            children.shadow(
                color: (
                    props.color ?? Color.black
                ).opacity(
                    // lower the opacity if no color or opacity was provided.
                    hasUserColor ? props.opacity ?? 1.0 : props.opacity ?? 0.35
                ),
                radius: props.radius ?? 10,
                x: props.x ?? 0,
                y: props.y ?? 5)
        case .foregroundColor:
            children.foregroundColor(props._0 ?? Color.primary)
        case .foregroundStyle:
            ForegroundStyleModifier(directive)
        case .ignoresSafeArea:
            children.ignoresSafeArea(edges: props.edges ?? .all)
        case .disabled:
            children.disabled(directive.props.isEmpty ? true : props.disabled ?? true)
        case .scaledToFill:
            children.scaledToFill()
        case .scaledToFit:
            children.scaledToFit()
        case .aspectRatio:
            children.aspectRatio(props._0 ?? 1.0, contentMode: props.contentMode ?? .fit)
        case .contentMode:
            children.aspectRatio(contentMode: props.contentMode ?? .fit)
        case .border:
            if let color: Color = props._0 ?? props.color {
                children.border(color, width: props.width ?? 1)
            } else {
                children.border(props._0 ?? Color.primary, width: props.width ?? 1)
            }
        case .compositingGroup:
            children.compositingGroup()
        case .drawingGroup:
            children.drawingGroup()
        case .scrollClipDisabled:
            if #available(iOS 16.0, macOS 14.0, *) {
                children.scrollClipDisabled(props.directive.props.isEmpty ? true : props._0 ?? true)
            } else {
                children
            }
        case .none:
            EmptyView()
        }
    }
    
    var children: ComponentView {
        ComponentView(directive.children)
    }
}

struct ForegroundStyleModifier: View {
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var children: some View {
        ComponentView(directive.children)
    }
    
    var body: some View {
        if let material = Material(props._0 ?? "") {
            children.foregroundStyle(material)
        } else if let color = Color(props._0 ?? "") {
            children.foregroundStyle(color)
//        } else if let gradient = Gradient(props._0 ?? "") { // TODO
            
        } else {
            if let color: Color = props.color {
                children.foregroundColor(color)
            } else if let material: Material = props.material {
                children.foregroundStyle(material)
            } else {
                children
            }
        }
    }
}
