import SwiftUI

public struct TextEditorComponent: Component {
    public static var directiveName: String = "TextEditor"
    
    @State private var text: String = ""
    
    init(text: String = "") {
        self._text = State(initialValue: text)
    }
}

extension TextEditorComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        let initialText: String = directive.rawValue() ?? directive["text"] ?? directive["value"] ?? ""
        self.init(text: initialText)
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitTextEditor(self)
    }
}

extension TextEditorComponent: View {
    public var body: some View {
        TextEditor(text: $text)
    }
}
