import SwiftUI

struct ImageComponent: Component {
    static var directiveName: String = "Image"
    
    let name: String?
    let url: URL?
    let systemName: String?
    let resizable: Bool
}

extension ImageComponent {
    init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        name = directive["name"]
        url = directive["url"]
        systemName = directive["systemName"]
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
                RoundedRectangle(cornerRadius: 0)
                    .fill(.quaternary)
            }
        } else if let systemName = systemName {
            Image(systemName: systemName)
        }
    }
}
