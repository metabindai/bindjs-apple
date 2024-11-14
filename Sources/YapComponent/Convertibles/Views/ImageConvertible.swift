import SwiftUI

struct ImageConvertible: ComponentConvertible {
    var url: URL?
    var name: String?
    var systemName: String?
    
    init(_ component: Component) {
        if let url: String = component.decode("url"), let url = URL(string: url) {
            self.url = url
        } else if let name: String = component.decode("name") ?? component.decode("value") {
            self.name = name
        } else if let sfSymbolName: String = component.decode("systemName") {
            self.systemName = sfSymbolName
        }
    }
    
    var component: Component {
        if let url = url {
            return Component(type: Self.componentName, props: ["url": url.absoluteString])
        } else if let name = name {
            return Component(type: Self.componentName, props: ["name": name])
        } else if let systemName = systemName {
            return Component(type: Self.componentName, props: ["systemName": systemName])
        } else {
            return Component(type: Self.componentName, props: [:])
        }
    }
}

extension ImageConvertible: View {
    public var body: some View {
        if let url {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                Rectangle().fill(.quaternary)
            }
        } else if let name {
            // TODO: Sync with Dave
        } else if let systemName {
            Image(systemName: systemName)
        }
    }
}
