import SwiftUI

public struct SliderComponent: Component {
    public static var directiveName: String = "Slider"

    @EnvironmentObject private var context: BindJSContext

    public var value: Double?
    public var setValueId: String?
    public var lowerBound: Double
    public var upperBound: Double
    public var step: Double?
    public var label: String?
    public var minimumValueLabel: Component?
    public var maximumValueLabel: Component?
    public var environmentId: String?
}

extension SliderComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        value = directive["value"]
        setValueId = directive["setValueId"]
        lowerBound = directive["lowerBound"] ?? 0
        upperBound = directive["upperBound"] ?? 1
        step = directive["step"]
        label = directive["label"]
        minimumValueLabel = (directive["minimumValueLabel"] as Directive?).flatMap(makeComponent)
        maximumValueLabel = (directive["maximumValueLabel"] as Directive?).flatMap(makeComponent)
        environmentId = directive["environmentId"]
    }

    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitSlider(self)
    }
}

extension SliderComponent: View {
    public var body: some View {
        let currentValue = min(max(value ?? lowerBound, lowerBound), upperBound)

        let binding = Binding<Double>(
            get: { currentValue },
            set: { newValue in
                guard let setValueId else { return }
                if let environmentId {
                    context.restoreEnvironment(id: environmentId)
                }
                _ = context.callEventHandler(id: setValueId, arguments: newValue)
            }
        )

        Group {
            if let step {
                Slider(value: binding, in: lowerBound...upperBound, step: step) {
                    if let label {
                        Text(label)
                    } else {
                        EmptyView()
                    }
                } minimumValueLabel: {
                    if let minimumValueLabel {
                        ComponentView(minimumValueLabel)
                    }
                } maximumValueLabel: {
                    if let maximumValueLabel {
                        ComponentView(maximumValueLabel)
                    }
                }
            } else {
                Slider(value: binding, in: lowerBound...upperBound) {
                    if let label {
                        Text(label)
                    } else {
                        EmptyView()
                    }
                } minimumValueLabel: {
                    if let minimumValueLabel {
                        ComponentView(minimumValueLabel)
                    }
                } maximumValueLabel: {
                    if let maximumValueLabel {
                        ComponentView(maximumValueLabel)
                    }
                }
            }
        }
    }
}
