import SwiftUI

struct ImageComponent: Component {
    static var directiveName: String = "Image"
    
    let name: String?
    let url: URL?
    let systemImage: String?
    let resizable: Bool
}

extension ImageComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        name = directive["name"]
        url = directive["url"]
        systemImage = directive["systemImage"]
        resizable = directive["resizable"] ?? true
    }
}

extension ImageComponent: View {
    var body: some View {
        if let name = name {
            if resizable {
                Image(name)
                    .resizable()
            } else {
                Image(name)
            }
        } else if let url = url {
            AsyncImage(url: url) { image in
                if resizable {
                    image.resizable()
                } else {
                    image
                }
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary)
            }
        } else if let systemImage = systemImage {
            Image(systemName: systemImage)
        }
    }
}
