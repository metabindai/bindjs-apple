import SwiftUI

struct ForEachView: View {
    @Environment(\.componentRuntime) private var componentRuntime
    
    let forEachComponent: ForEachComponent
    
    var body: some View {
        if let data = componentRuntime.restoreForEachData(id: forEachComponent.dataId) {
            ForEach(0..<forEachComponent.count, id: \.self) { index in
                if let item = data.atIndex(index),
                   let result = componentRuntime.callForEachFunction(id: forEachComponent.functionId, element: item, index: Int32(index))
                {
                    ComponentView(decode(from: result.toString()))
                }
            }
        }
    }
}
