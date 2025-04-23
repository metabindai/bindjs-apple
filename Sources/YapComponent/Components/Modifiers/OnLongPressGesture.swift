import SwiftUI

struct OnLongPressGestureComponent: Component {
    static var directiveName: String = "onLongPressGesture"
    
    let minimumDuration: Double
    let maximumDistance: Double
    let handlerId: String
}

extension OnLongPressGestureComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        minimumDuration = directive["minimumDuration"] ?? 0.5
        maximumDistance = directive["maximumDistance"] ?? 10.0
        handlerId = directive["handlerId"] ?? ""
    }
}

extension OnLongPressGestureComponent: ViewModifier {
    func body(content: Content) -> some View {
        OnLongPressGestureWrapper(configuration: self, content: content)
    }
}

struct OnLongPressGestureWrapper<Content: View>: View {
    let configuration: OnLongPressGestureComponent
    let content: Content
    
    @GestureState private var phase: GesturePhase = .possible
    @GestureState private var location: CGPoint = .zero
    @EnvironmentObject private var runtime: ComponentRuntime
    
    private func callHandler(_ newPhase: GesturePhase) {
        runtime.callEventHandler(
            id: configuration.handlerId,
            arguments: [
                "phase": newPhase.rawValue,
                "locationInView": ["x": location.x, "y": location.y]
            ]
        )
    }
    
    var body: some View {
        content
            .gesture(
                LongPressGesture(
                    minimumDuration: configuration.minimumDuration,
                    maximumDistance: configuration.maximumDistance
                )
                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                // Update the phase
                    .updating($phase) { value, state, _ in
                        switch value {
                        case .first(true):
                            state = .began
                            callHandler(.began)
                        case .second(true, _):
                            state = .changed
                            callHandler(.changed)
                        default:
                            break
                        }
                    }
                // Extract the drag location
                    .updating($location) { value, state, _ in
                        if case .second(true, let drag?) = value {
                            state = drag.location
                        }
                    }
                // Final end/cancel
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag?):
                            // ended normally
                            callHandler(.ended)
                        default:
                            // moved too far or aborted
                            callHandler(.cancelled)
                        }
                    }
            )
    }
}
