import SwiftUI

public struct TextComponent: AutomaticComponentConvertible {
    public var text: String = ""
    
    init(_ text: String) {
        self.text = text
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("text", \Self.text)
        ]
    }
}

extension TextComponent: View {
    public var body: some View {
        Text(text)
    }
}
