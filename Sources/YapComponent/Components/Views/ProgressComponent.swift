import SwiftUI

public struct ProgressComponent: AutomaticComponentConvertible {
    public var value: Double?
    public var total: Double?
    
    public init(value: Double? = nil, total: Double? = nil) {
        self.value = value
        self.total = total
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
           ("value", \Self.value),
           ("total", \Self.total)
       ]
    }
}

extension ProgressComponent: View {
    public var body: some View {
        if let value, let total {
            ProgressView(value: value, total: total)
        } else {
            ProgressView()
        }
    }
}
