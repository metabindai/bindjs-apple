import SwiftUI

public class ComponentContext: ObservableObject {
    var parent: ComponentContext?
    var values: [String: Component] = [:]
    
    public init(parent: ComponentContext? = nil) {
        self.parent = parent
    }
    
    public func get(_ key: String) -> Component? {
        values[key] ?? parent?.get(key)
    }
    
    public func assign(_ key: String, _ value: Component) {
        if values.keys.contains(key) || parent == nil {
            values[key] = value
        } else {
            parent?.assign(key, value)
        }
    }
    
    public func define(_ key: String, _ value: Component) {
        if !values.keys.contains(key) {
            values[key] = value
        }
    }
}
