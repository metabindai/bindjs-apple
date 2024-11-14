import SwiftUI

struct ForEachView: View {
    @Environment(\.componentRuntime) private var componentRuntime
    
    let forEachComponent: ForEachComponent
    
    var body: some View {
        if let data = componentRuntime.restoreData(id: forEachComponent.dataId),
           let callback = componentRuntime.restoreFunction(id: forEachComponent.functionId)
        {
            ForEach(0..<forEachComponent.count, id: \.self) { index in
                if let item = data.atIndex(index),
                   let result = callback.call(withArguments: [item, Int32(index)]), !result.isUndefined {
                    ComponentView(decode(from: result.toString()))
                }
            }
        }
    }
}
