import SwiftUI

struct PaddingComponent: Component {
    static var directiveName: String = "padding"
    
    let top: CGFloat?
    let leading: CGFloat?
    let bottom: CGFloat?
    let trailing: CGFloat?
}

extension PaddingComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        top = directive["top"]
        leading = directive["leading"]
        bottom = directive["bottom"]
        trailing = directive["trailing"]
    }
}

extension PaddingComponent: ViewModifier {
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
