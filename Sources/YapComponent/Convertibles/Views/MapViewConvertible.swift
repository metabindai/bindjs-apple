import SwiftUI
import MapKit

struct MapViewConvertible: ComponentConvertible {
    // Properties to configure the map
    let region: MKCoordinateRegion
    let interactionModes: MapInteractionModes
    
    init(_ component: Component) {
        // Parse coordinate position
        let latitude: Double = component.decode("latitude") ?? 37.3973
        let longitude: Double = component.decode("longitude") ?? -122.1068
        let span: Double = component.decode("span") ?? 0.05
        
        // Create the region
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: span,
                longitudeDelta: span
            )
        )
        
        // Parse interaction modes
        let interactionModesString: String = component.decode("interactionModes") ?? "all"
        self.interactionModes = MapInteractionModes(stringValue: interactionModesString)
    }
    
    var component: Component {
        Component(
            type: Self.componentName,
            props: [
                "latitude": region.center.latitude,
                "longitude": region.center.longitude,
                "span": region.span.latitudeDelta,
                "interactionModes": interactionModes.stringValue
            ]
        )
    }
}

// MARK: - View Implementation
extension MapViewConvertible: View {
    var body: some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            Map(initialPosition: .region(region), interactionModes: interactionModes)
        } else {
            Map(coordinateRegion: .constant(region), interactionModes: interactionModes)
        }
    }
}

// MARK: - Helper Extensions
private extension MapInteractionModes {
    init(stringValue: String) {
        switch stringValue.lowercased() {
        case "all":
            self = .all
        case "pan":
            self = .pan
        case "zoom":
            self = .zoom
        case "none":
            self = []
        default:
            self = .all
        }
    }
    
    var stringValue: String {
        switch self {
        case .all:
            return "all"
        case .pan:
            return "pan"
        case .zoom:
            return "zoom"
        default:
            return "none"
        }
    }
}
