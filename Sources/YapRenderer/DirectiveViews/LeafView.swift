import SwiftUI
import YapComponent

struct LeafView: View {
    
    enum Name: String, CaseIterable {
        case Text
        case Button
        case Divider
        case Spacer
        case Progress
        case Image
        case Color
        case LinearGradient
    }
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var body: some View {
        switch Name(rawValue: directive.type) {
        case .Text: TextView(directive)
        case .Button: ButtonView(directive)
        case .Divider: Divider()
        case .Spacer: Spacer()
        case .Progress: ProgressViewWrapped(directive)
        case .Image: ImageView(directive)
        case .Color: ColorView(directive)
        case .LinearGradient: LinearGradientView(directive)
        case .none: EmptyView()
        }
    }
    
}

struct TextView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var concat: String {
        props.directive.children.map(String.init(describing:)).joined()
    }
    
    var firstImageChild: Image? {
        if let directive = directive.children.first as? Directive, directive.type == "Image" {
            let props = Props(directive)
            if let name: String = props.name {
                return Image(name)
            } else if let systemName: String = props.systemName {
                return Image(systemName: systemName)
            }
        }
        return nil
    }
    
    var body: some View {
        if let firstImageChild {
            Text(firstImageChild)
        } else {
            Text(props._0 ?? concat)
        }
    }
}

struct ButtonView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        Button(action: {
            if let action = props.action as? Closure {
                let _ = action()
            }
        }) {
            ComponentView(directive.children)
        }
    }
}

struct ProgressViewWrapped: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        if let total: Double = props.total {
            ProgressView(value: props.value, total: total)
        } else {
            ProgressView()
        }
    }
}

struct ImageView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        if let name: String = props.name {
            // What would we do to request from our library?
            Image(name)
                .resizable()
                .scaledToFit()
        } else if let url: URL = props.url {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.secondary)
                        .scaledToFit()
                }
            }
        } else if let systemName: String = props.systemName {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
        } else {
            EmptyView()
        }
    }
}

struct ColorView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        if let color: Color = props._0 {
            color
        }
    }
}

struct LinearGradientView: View {
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var colors: [Color] {
        directive.children.compactMap {
            if let directive = $0 as? Directive {
                return Color(directive)
            } else {
                return nil
            }
        }
    }
    
    var startPoint: UnitPoint {
        props.startPoint ?? .topLeading
    }
    
    var endPoint: UnitPoint {
        props.endPoint ?? .bottomTrailing
    }
    
    var body: some View {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}
