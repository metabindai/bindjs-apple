import SwiftUI

struct ProgressViewComponent: Component {
    static var directiveName: String = "ProgressView"
    
    let value: Double?
    let total: Double?
}

extension ProgressViewComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        value = directive["value"]
        total = directive["total"]
    }
}

extension ProgressViewComponent: View {
    var body: some View {
        if let value {
            if let total {
                ProgressView(value: value, total: total)
            } else {
                ProgressView(value: value)
            }
        } else {
            ProgressView()
        }
    }
}
