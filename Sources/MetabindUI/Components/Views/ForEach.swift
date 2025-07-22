import SwiftUI
import JavaScriptCore

public struct ForEachComponent: Component {
    public static var directiveName: String = "ForEach"
    
    @EnvironmentObject private var context: ComponentContext
    
    public let dataId: String
    public let count: Int
    public let functionId: String
    public let environmentId: String
}

extension ForEachComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        dataId = directive["dataId"] ?? ""
        count = directive["count"] ?? 0
        functionId = directive["functionId"] ?? ""
        environmentId = directive["environmentId"] ?? ""
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitForEach(self)
    }
}

extension ForEachComponent: View {
    
    public var body: some View {
        if let data = context.restoreForEachData(id: dataId),
           case _ = context.restoreEnvironment(id: environmentId) {
            ForEach(0..<count, id: \.self) { index in
                if let item = data.atIndex(index),
                   let json = context.callForEachFunction(id: functionId, element: item, index: Int32(index))?.toString(),
                   let data = json.data(using: .utf8),
                   let directive = try? JSONDecoder().decode(Directive.self, from: data),
                   let component = makeComponent(directive)
                {
                    ComponentView(component)
                }
            }
        }
    }
}
