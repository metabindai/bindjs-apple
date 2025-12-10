import SwiftUI

public struct NavigationDestinationComponent: Component {
    public static var directiveName: String = "navigationDestination"

    @EnvironmentObject private var context: BindJSContext

    @State var destination: Component

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
            let isPresentedBinding = Binding(
                get: { self.isPresented },
                set: { handleChange(isPresented: $0) }
            )

            content
                .navigationDestination(isPresented: isPresentedBinding) {
                    ComponentView(self.destination)
                }
                .onChange(of: self.isPresented) { old, new in
                    reloadDestination(isPresented: new)
                }
                .onAppear {
                    reloadDestination(isPresented: self.isPresented)
                }
        } else {
            content
        }
    }
}
