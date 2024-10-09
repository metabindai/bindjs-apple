import SwiftUI

extension AnyView: ComponentProtocol {
    public func accept<V>(_ visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.defaultVisit(self)
    }
}
