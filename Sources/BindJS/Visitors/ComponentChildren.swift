public extension Component {
    var componentChildren: [any Component] {
        var visitor = ComponentChildren()
        return visitor.visit(self)
    }
}

private struct ComponentChildren: ComponentVisitor {
    
    func defaultVisit(_ component: any Component) -> [any Component] {
        []
    }
    
    mutating func visitButton(_ button: ButtonComponent) -> [any Component] {
        [button.label]
    }
    
    mutating func visitCall(_ call: ComponentCall) -> [any Component] {
        call.children
    }
    
    mutating func visitGroup(_ group: GroupComponent) -> [any Component] {
        group.content
    }
    
    mutating func visitHStack(_ hStack: HStackComponent) -> [any Component] {
        hStack.children
    }
    
    mutating func visitModified(_ modified: ModifiedComponent) -> [any Component] {
        modified.content + [modified.modifier]
    }
    
    mutating func visitPicker(_ picker: PickerComponent) -> [any Component] {
        picker.children
    }
    
    mutating func visitScrollView(_ scrollView: ScrollViewComponent) -> [any Component] {
        scrollView.content
    }
    
    mutating func visitSection(_ section: SectionComponent) -> [any Component] {
        var children = section.content
        if let header = section.header {
            children.append(header)
        }
        if let footer = section.footer {
            children.append(footer)
        }
        return children
    }
    
    mutating func visitUnresolved(_ unresolved: UnresolvedComponent) -> [any Component] {
        unresolved.children
    }
    
    mutating func visitVStack(_ vStack: VStackComponent) -> [any Component] {
        vStack.children
    }
    
    mutating func visitZStack(_ zStack: ZStackComponent) -> [any Component] {
        zStack.children
    }
    
    mutating func visitCircle(_ circle: CircleComponent) -> [any Component] {
        switch circle.style {
        case .fill(let component):
            return [component]
        case .stroke(let component, _):
            return [component]
        case .none:
            return []
        }
    }
    
    mutating func visitEllipse(_ ellipse: EllipseComponent) -> [any Component] {
        switch ellipse.style {
        case .fill(let component):
            return [component]
        case .stroke(let component, _):
            return [component]
        case .none:
            return []
        }
    }
    
    mutating func visitRectangle(_ rectangle: RectangleComponent) -> [any Component] {
        switch rectangle.style {
        case .fill(let component):
            return [component]
        case .stroke(let component, _):
            return [component]
        case .none:
            return []
        }
    }
    
    mutating func visitRoundedRectangle(_ roundedRectangle: RoundedRectangleComponent) -> [any Component] {
        switch roundedRectangle.style {
        case .fill(let component):
            return [component]
        case .stroke(let component, _):
            return [component]
        case .none:
            return []
        }
    }
    
    mutating func visitCapsule(_ capsule: CapsuleComponent) -> [any Component] {
        switch capsule.style {
        case .fill(let component):
            return [component]
        case .stroke(let component, _):
            return [component]
        case .none:
            return []
        }
    }
    
    mutating func visitAccessibilityRepresentation(_ accessibilityRepresentation: AccessibilityRepresentationComponent) -> [any Component] {
        [accessibilityRepresentation.representation]
    }
    
    mutating func visitBackground(_ background: BackgroundComponent) -> [any Component] {
        [background.content]
    }
    
    mutating func visitBorder(_ border: BorderComponent) -> [any Component] {
        [border.style]
    }
    
    mutating func visitForegroundStyle(_ foregroundStyle: ForegroundStyleComponent) -> [any Component] {
        [foregroundStyle.style]
    }
    
    mutating func visitOverlay(_ overlay: OverlayComponent) -> [any Component] {
        [overlay.content]
    }
}
