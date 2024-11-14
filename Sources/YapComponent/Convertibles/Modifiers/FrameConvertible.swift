import SwiftUI

struct FrameConvertible: ComponentConvertible {
    let width: Double?
    let height: Double?
    let alignment: String?
    
    init(_ component: Component) {
        width = component.decode("width")
        height = component.decode("height")
        alignment = component.decode("alignment")
    }
    
    var component: Component {
        var props: [String: AST] = [:]
        if let width = width {
            props["width"] = width
        }
        if let height = height {
            props["height"] = height
        }
        if let alignment = alignment {
            props["alignment"] = alignment
        }
        return Component(
            type: Self.componentName,
            props: props
        )
    }
}

extension FrameConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.frame(
            width: width.map { CGFloat($0) },
            height: height.map { CGFloat($0) },
            alignment: alignment.map { Alignment(stringValue: $0) } ?? .center
        )
    }
}

struct FlexFrameConvertible: ComponentConvertible {
    var minWidth: Double?
    var idealWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var idealHeight: Double?
    var maxHeight: Double?
    var alignment: String?
    
    static var keys: [String] { ["minWidth", "idealWidth", "maxWidth", "minHeight", "idealHeight", "maxHeight"] }
    
    init(_ component: Component) {
        minWidth = component.decode("minWidth")
        idealWidth = component.decode("idealWidth")
        maxWidth = component.decode("maxWidth")
        minHeight = component.decode("minHeight")
        idealHeight = component.decode("idealHeight")
        maxHeight = component.decode("maxHeight")
        alignment = component.decode("alignment")
    }
    
    var component: Component {
        var props: [String: AST] = [:]
        if let minWidth = minWidth {
            props["minWidth"] = minWidth
        }
        if let idealWidth = idealWidth {
            props["idealWidth"] = idealWidth
        }
        if let maxWidth = maxWidth {
            props["maxWidth"] = maxWidth
        }
        if let minHeight = minHeight {
            props["minHeight"] = minHeight
        }
        if let idealHeight = idealHeight {
            props["idealHeight"] = idealHeight
        }
        if let maxHeight = maxHeight {
            props["maxHeight"] = maxHeight
        }
        if let alignment = alignment {
            props["alignment"] = alignment
        }
        return Component(
            type: Self.componentName,
            props: props
        )
    }
}

extension FlexFrameConvertible: ViewModifier {
    
    func body(content: Content) -> some View {
        content.frame(
            minWidth: minWidth.map { CGFloat($0) },
            idealWidth: idealWidth.map { CGFloat($0) },
            maxWidth: maxWidth.map { CGFloat($0) },
            minHeight: minHeight.map { CGFloat($0) },
            idealHeight: idealHeight.map { CGFloat($0) },
            maxHeight: maxHeight.map { CGFloat($0) },
            alignment: alignment.map { Alignment(stringValue: $0) } ?? .center
        )
    }
}
