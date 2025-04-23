import SwiftUI

protocol Component {
    static var directiveName: String { get }
    init?(from directive: Directive)
}

extension Component {
    func modifier(_ m: Component) -> Component {
        ModifiedComponent(content: [self], modifier: m)
    }
}
