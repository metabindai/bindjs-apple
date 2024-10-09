import SwiftUI

public struct ImageComponent: AutomaticComponentConvertible {
    public var name: String?
    public var url: String?
    public var systemImage: String?
    public var resizable: Bool?
    
    public init(name: String? = nil, url: String? = nil, systemImage: String? = nil, resizable: Bool? = nil) {
        self.name = name
        self.url = url
        self.systemImage = systemImage
        self.resizable = resizable
    }
    
    public init() {}
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("name", \Self.name),
            ("url", \Self.url),
            ("systemImage", \Self.systemImage),
            ("resizable", \Self.resizable)
        ]
    }
}


extension ImageComponent: View {
    
    public var body: some View {
        if let resizable, resizable {
            resizableImage
        } else {
            nonResizableImage
        }
    }
    
    @ViewBuilder
    var nonResizableImage: some View {
        if let name {
            Image(name)
        } else if let url, case let url = URL(string: url) {
            AsyncImage(url: url) {
                $0
            } placeholder: {
                ProgressView()
            }
        } else if let systemImage {
            Image(systemName: systemImage)
        }
    }
    
    @ViewBuilder
    var resizableImage: some View {
        if let name {
            Image(name)
                .resizable()
        } else if let url, case let url = URL(string: url) {
            AsyncImage(url: url) {
                $0.resizable()
            } placeholder: {
                ProgressView()
            }
        } else if let systemImage {
            Image(systemName: systemImage)
                .resizable()
        }
    }
}
