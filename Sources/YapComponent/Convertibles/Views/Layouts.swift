import SwiftUI

struct HStackConvertible: ComponentConvertible {
    let alignment: String
    let spacing: Double?
    let children: AST
    
    init(_ component: Component) {
        alignment = component.decode("alignment") ?? "center"
        spacing = component.decode("spacing")
        children = component.children
    }
    
    var component: Component {
        
        var props: [String: AST] = [
            "alignment": alignment,
            "children": children
        ]
        if let spacing = spacing {
            props["spacing"] = spacing
        }
        
        return Component(type: Self.componentName, props: props)
    }
}

extension HStackConvertible: View {
    
    var body: some View {
        HStack(alignment: .init(stringValue: alignment), spacing: spacing.map { CGFloat($0) }) {
            ComponentView(children)
        }
    }
}

extension VerticalAlignment {
    init(stringValue: String) {
        switch stringValue {
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "firstTextBaseline":
            self = .firstTextBaseline
        case "lastTextBaseline":
            self = .lastTextBaseline
        case "center":
            self = .center
        default:
            self = .center
        }
    }
}



struct VStackConvertible: ComponentConvertible {
    let alignment: String
    let spacing: Double?
    let children: AST
    
    init(_ component: Component) {
        alignment = component.decode("alignment") ?? "center"
        spacing = component.decode("spacing")
        children = component.children
    }
    
    var component: Component {
        
        var props: [String: AST] = [
            "alignment": alignment,
            "children": children
        ]
        if let spacing = spacing {
            props["spacing"] = spacing
        }
        
        return Component(type: Self.componentName, props: props)
    }
}

extension VStackConvertible: View {
    
    var body: some View {
        VStack(alignment: .init(stringValue: alignment), spacing: spacing.map { CGFloat($0) }) {
            ComponentView(children)
        }
    }
}

extension HorizontalAlignment {
    init(stringValue: String) {
        switch stringValue {
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "center":
            self = .center
        default:
            self = .center
        }
    }
}

struct ZStackConvertible: ComponentConvertible {
    let alignment: String
    let children: AST
    
    init(_ component: Component) {
        alignment = component.decode("alignment") ?? "center"
        children = component.children
    }
    
    var component: Component {
        
        return Component(type: Self.componentName, props: [
            "alignment": alignment,
            "children": children
        ])
    }
}

extension ZStackConvertible: View {
    
    var body: some View {
        ZStack(alignment: .init(stringValue: alignment)) {
            ComponentView(children)
        }
    }
}

extension Alignment {
    init(stringValue: String) {
        switch stringValue {
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "center":
            self = .center
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "bottomLeading":
            self = .bottomLeading
        case "bottomTrailing":
            self = .bottomTrailing
        case "topLeading":
            self = .topLeading
        case "topTrailing":
            self = .topTrailing
        default:
            self = .center
        }
    }
}


