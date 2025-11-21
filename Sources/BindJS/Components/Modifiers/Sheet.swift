import SwiftUI

public struct SheetComponent: Component {
    public static var directiveName: String = "sheet"
    
    @EnvironmentObject private var context: BindJSContext
    
    @State var content: Component

    public var isPresented: Bool
    public var contentHandlerId : String?
    public var dismissHandlerId : String?
    public var setIsPresentedHandlerId: String?

    func handleChange(isPresented: Bool) {
        if let setIsPresentedHandlerId {
            context.callEventHandler(id: setIsPresentedHandlerId, arguments: [isPresented])
        }
    }
    
    func handleDismiss() {
        if let dismissHandlerId {
            context.callEventHandler(id: dismissHandlerId, arguments: [isPresented])
        }
    }
    
    func reloadContent(isPresented: Bool) {
        guard let contentHandlerId else { return }
        guard isPresented else { return }

        if let jsValue = context.callEventHandler(id: contentHandlerId, arguments: []), let directive = jsValue.toDirective() {
            if let component = makeComponent(directive) {
                self.content = component
            }
        }
    }
}

extension SheetComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        content = EmptyComponent()
        
        isPresented = directive["isPresented"] ?? false
        contentHandlerId = directive["contentHandlerId"]
        setIsPresentedHandlerId = directive["setIsPresentedHandlerId"]
        dismissHandlerId = directive["dismissHandlerId"]
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitSheet(self)
    }
}

extension SheetComponent: ViewModifier {
    public func body(content: Content) -> some View {
        
        let isPresented = Binding(get: {
            self.isPresented
        }, set: {
            handleChange(isPresented: $0)
        })
        
        content
            .sheet(isPresented: isPresented, onDismiss: {
                handleDismiss()
            }) {
                ComponentView(self.content)
            }.onChange(of: self.isPresented) { old, new in
                reloadContent(isPresented: new)
            }.onAppear {
                reloadContent(isPresented: self.isPresented)
            }
    }
}
