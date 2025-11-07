public protocol ComponentRewriter: ComponentVisitor where Result == Component {
    
}

public extension ComponentRewriter {
    
    mutating func defaultVisit(_ component: any Component) -> Result {
        component
    }
    
    mutating func visitButton(_ button: ButtonComponent) -> Result {
        var copy = button
        copy.label = button.label.accept(visitor: &self)
        return copy
    }
    
    mutating func visitCall(_ call: ComponentCall) -> Result {
        var copy = call
        copy.children = call.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitGroup(_ group: GroupComponent) -> Result {
        var copy = group
        copy.content = group.content.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitHStack(_ hStack: HStackComponent) -> Result {
        var copy = hStack
        copy.children = hStack.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitModified(_ modified: ModifiedComponent) -> Result {
        var copy = modified
        copy.content = modified.content.map { $0.accept(visitor: &self) }
        copy.modifier = modified.modifier.accept(visitor: &self)
        return copy
    }
    
    mutating func visitPicker(_ picker: PickerComponent) -> Result {
        var copy = picker
        copy.children = picker.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitScrollView(_ scrollView: ScrollViewComponent) -> Result {
        var copy = scrollView
        copy.content = scrollView.content.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitSection(_ section: SectionComponent) -> Result {
        var copy = section
        copy.content = section.content.map { $0.accept(visitor: &self) }
        if let header = section.header {
            copy.header = header.accept(visitor: &self)
        }
        if let footer = section.footer {
            copy.footer = footer.accept(visitor: &self)
        }
        return copy
    }
    
    mutating func visitUnresolved(_ unresolved: UnresolvedComponent) -> Result {
        var copy = unresolved
        copy.children = unresolved.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitVStack(_ vStack: VStackComponent) -> Result {
        var copy = vStack
        copy.children = vStack.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitZStack(_ zStack: ZStackComponent) -> Result {
        var copy = zStack
        copy.children = zStack.children.map { $0.accept(visitor: &self) }
        return copy
    }
    
    mutating func visitCircle(_ circle: CircleComponent) -> Result {
        var copy = circle
        switch circle.style {
        case .fill(let component):
            copy.style = .fill(component.accept(visitor: &self))
        case .stroke(let component, let lineWidth):
            copy.style = .stroke(component.accept(visitor: &self), lineWidth: lineWidth)
        case .none:
            copy.style = nil
        }
        return copy
    }
    
    mutating func visitEllipse(_ ellipse: EllipseComponent) -> Result {
        var copy = ellipse
        switch ellipse.style {
        case .fill(let component):
            copy.style = .fill(component.accept(visitor: &self))
        case .stroke(let component, let lineWidth):
            copy.style = .stroke(component.accept(visitor: &self), lineWidth: lineWidth)
        case .none:
            copy.style = nil
        }
        return copy
    }
    
    mutating func visitRectangle(_ rectangle: RectangleComponent) -> Result {
        var copy = rectangle
        switch rectangle.style {
        case .fill(let component):
            copy.style = .fill(component.accept(visitor: &self))
        case .stroke(let component, let lineWidth):
            copy.style = .stroke(component.accept(visitor: &self), lineWidth: lineWidth)
        case .none:
            copy.style = nil
        }
        return copy
    }
    
    mutating func visitRoundedRectangle(_ roundedRectangle: RoundedRectangleComponent) -> Result {
        var copy = roundedRectangle
        switch roundedRectangle.style {
        case .fill(let component):
            copy.style = .fill(component.accept(visitor: &self))
        case .stroke(let component, let lineWidth):
            copy.style = .stroke(component.accept(visitor: &self), lineWidth: lineWidth)
        case .none:
            copy.style = nil
        }
        return copy
    }
    
    mutating func visitCapsule(_ capsule: CapsuleComponent) -> Result {
        var copy = capsule
        switch capsule.style {
        case .fill(let component):
            copy.style = .fill(component.accept(visitor: &self))
        case .stroke(let component, let lineWidth):
            copy.style = .stroke(component.accept(visitor: &self), lineWidth: lineWidth)
        case .none:
            copy.style = nil
        }
        return copy
    }
    
    mutating func visitAccessibilityRepresentation(_ accessibilityRepresentation: AccessibilityRepresentationComponent) -> Result {
        var copy = accessibilityRepresentation
        copy.representation = accessibilityRepresentation.representation.accept(visitor: &self)
        return copy
    }
    
    mutating func visitBackground(_ background: BackgroundComponent) -> Result {
        var copy = background
        copy.content = background.content.accept(visitor: &self)
        return copy
    }
    
    mutating func visitBorder(_ border: BorderComponent) -> Result {
        var copy = border
        copy.style = border.style.accept(visitor: &self)
        return copy
    }
    
    mutating func visitForegroundStyle(_ foregroundStyle: ForegroundStyleComponent) -> Result {
        var copy = foregroundStyle
        copy.style = foregroundStyle.style.accept(visitor: &self)
        return copy
    }
    
    mutating func visitOverlay(_ overlay: OverlayComponent) -> Result {
        var copy = overlay
        copy.content = overlay.content.accept(visitor: &self) 
        return copy
    }
}
