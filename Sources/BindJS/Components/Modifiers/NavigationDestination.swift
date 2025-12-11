import SwiftUI

public struct NavigationDestinationComponent: Component {
    public static var directiveName: String = "navigationDestination"

    @EnvironmentObject private var context: BindJSContext

    @State var destination: Component

    @State var internalIsPresentedState: Bool = false
    
    public var isPresented: Bool
    public var destinationHandlerId: String?
    public var setIsPresentedHandlerId: String?

    func handleChange(isPresented: Bool) {
        if let setIsPresentedHandlerId {
            context.callEventHandler(id: setIsPresentedHandlerId, arguments: isPresented)
        }
    }

    func reloadDestination(isPresented: Bool) {
        guard let destinationHandlerId else { return }
        guard isPresented else { return }

        if let jsValue = context.callEventHandler(id: destinationHandlerId, arguments: []), let directive = jsValue.toDirective() {
            if let component = makeComponent(directive) {
                self.destination = component
            }
        }
    }
}

extension NavigationDestinationComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        destination = EmptyComponent()

        isPresented = directive["isPresented"] ?? false
        destinationHandlerId = directive["destinationHandlerId"]
        setIsPresentedHandlerId = directive["setIsPresentedHandlerId"]
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitNavigationDestination(self)
    }
}

extension NavigationDestinationComponent: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            content
                .navigationDestination(isPresented: $internalIsPresentedState) {
                    NavigationDestinationContentView(destinationHandlerId: destinationHandlerId)
                        .environmentObject(context)
                }
                .onChange(of: isPresented) { old, new in
                    internalIsPresentedState = new
                }
                .onChange(of: internalIsPresentedState) { old, new in
                    handleChange(isPresented: new)
                }
        } else {
            content
        }
    }
}


struct NavigationDestinationContentView : View {
    var destinationHandlerId: String?
    @State var destination: Component = ColorComponent(storage: .name("clear"), opacity: 0)
    @EnvironmentObject private var context: BindJSContext

    func reloadDestination() {
        guard let destinationHandlerId else { return }
        
        if let jsValue = context.callEventHandler(id: destinationHandlerId, arguments: []),
           let directive = jsValue.toDirective(),
           let component = makeComponent(directive) {
            self.destination = component
        }
    }
    
    var body : some View {
        ComponentView(destination)
            .onAppear {
                reloadDestination()
            }
    }
}
