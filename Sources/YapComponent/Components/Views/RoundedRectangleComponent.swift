import SwiftUI

public struct RoundedRectangleComponent: AutomaticComponentConvertible {
    public var cornerRadius: Double = 8.0
    
    public init(cornerRadius: Double) {
        self.cornerRadius = cornerRadius
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("rawValue", \Self.cornerRadius)
        ]
    }
}

extension RoundedRectangleComponent: View {
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}
