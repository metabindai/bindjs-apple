import SwiftUI
import JavaScriptCore

struct ForEachComponent: Component {
    static var directiveName: String = "ForEach"
    
    @EnvironmentObject private var runtime: ComponentRuntime
    
    let dataId: String
    let count: Int
    let functionId: String
    let environmentId: String
}

extension ForEachComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        dataId = directive["dataId"] ?? ""
        count = directive["count"] ?? 0
        functionId = directive["functionId"] ?? ""
        environmentId = directive["environmentId"] ?? ""
    }
}

extension ForEachComponent: View {
    
    var body: some View {
        if let data = runtime.restoreForEachData(id: dataId),
           case _ = runtime.restoreEnvironment(id: environmentId) {
            ForEach(0..<count, id: \.self) { index in
                if let item = data.atIndex(index),
                   let json = runtime.callForEachFunction(id: functionId, element: item, index: Int32(index))?.toString(),
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
