import SwiftUI

public struct NavigationLinkComponent: Component {
    public static var directiveName: String = "NavigationLink"

    @EnvironmentObject private var context: BindJSContext

    @State var destination: Component

    public var label: Component
    public var destinationHandlerId: String?

    func reloadDestination() {
        guard let destinationHandlerId else { return }

        if let jsValue = context.callEventHandler(id: destinationHandlerId, arguments: []),
           let directive = jsValue.toDirective(),
           let component = makeComponent(directive) {
            self.destination = component
        }
    }
}

extension NavigationLinkComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        destination = EmptyComponent()
        label = directive["label"].flatMap(makeComponent) ?? TextComponent("Link")
        destinationHandlerId = directive["destinationHandlerId"]
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitNavigationLink(self)
    }
}

extension NavigationLinkComponent: View {
    public var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            NavigationLink {
                ComponentView(destination)
            } label: {
                ComponentView(label)
            }
            .onAppear {
                reloadDestination()
            }
        } else {
            NavigationLink(destination: ComponentView(destination)) {
                ComponentView(label)
            }
            .onAppear {
                reloadDestination()
            }
        }
    }
}
