import SwiftUI

public struct TextComponent: Component {
    public static var directiveName: String = "Text"
    
    public var text: String
    
    init(_ string: String) {
        self.text = string
    }
}

extension TextComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        text = directive.rawValue() ?? ""
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitText(self)
    }
}

extension TextComponent: View {
    public var body: some View {
        Text(text)
    }
}
