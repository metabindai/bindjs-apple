import SwiftUI

struct PaddingConvertible: ComponentConvertible {
    var top: Double?
    var leading: Double?
    var bottom: Double?
    var trailing: Double?
    
    init(_ component: Component) {
        top = component.decode("top") ?? component.decode("vertical")
        leading = component.decode("leading") ?? component.decode("horizontal")
        bottom = component.decode("bottom") ?? component.decode("vertical")
        trailing = component.decode("trailing") ?? component.decode("horizontal")
        
        if let value: Double = component.decode("all") ?? component.decode("value") {
            top = value
            leading = value
            bottom = value
            trailing = value
        }
    }
    
    var component: Component {
        var props: [String: AST] = [:]
        if let top = top {
            props["top"] = top
        }
        if let leading = leading {
            props["leading"] = leading
        }
        if let bottom = bottom {
            props["bottom"] = bottom
        }
        if let trailing = trailing {
            props["trailing"] = trailing
        }
        return Component(type: Self.componentName, props: props)
    }
}

extension PaddingConvertible: ViewModifier {
    
    var edgeSet: Edge.Set {
        if top == nil, leading == nil, bottom == nil, trailing == nil {
            return .all
        }
        var edgeSet: Edge.Set = []
        if top != nil {
            edgeSet.insert(.top)
        }
        if leading != nil {
            edgeSet.insert(.leading)
        }
        if bottom != nil {
            edgeSet.insert(.bottom)
        }
        if trailing != nil {
            edgeSet.insert(.trailing)
        }
        return edgeSet
    }
    
    var edgeInsets: EdgeInsets? {
        if top == nil, leading == nil, bottom == nil, trailing == nil {
            return nil
        }
        return .init(top: top ?? 0, leading: leading ?? 0, bottom: bottom ?? 0, trailing: trailing ?? 0)
    }
    
    func body(content: Content) -> some View {
        content.modifier(_PaddingLayout(edges: edgeSet, insets: edgeInsets))
    }
}
