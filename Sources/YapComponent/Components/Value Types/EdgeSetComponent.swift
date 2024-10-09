import SwiftUI

public struct EdgeSetComponent: AutomaticComponentConvertible {
    var top: Bool = false
    var leading: Bool = false
    var bottom: Bool = false
    var trailing: Bool = false
    
    public init(top: Bool = false, leading: Bool = false, bottom: Bool = false, trailing: Bool = false) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    public init() {
       
    }
    
    public static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("top", \Self.top),
            ("leading", \Self.leading),
            ("bottom", \Self.bottom),
            ("trailing", \Self.trailing)
        ]
    }
}

public extension EdgeSetComponent {
    static var horizontal: EdgeSetComponent {
        EdgeSetComponent(leading: true, trailing: true)
    }
    
    static var vertical: EdgeSetComponent {
        EdgeSetComponent(top: true, bottom: true)
    }
    
    static var all: EdgeSetComponent {
        EdgeSetComponent(top: true, leading: true, bottom: true, trailing: true)
    }
    
    static var top: EdgeSetComponent {
        EdgeSetComponent(top: true)
    }
    
    static var leading: EdgeSetComponent {
        EdgeSetComponent(leading: true)
    }
    
    static var bottom: EdgeSetComponent {
        EdgeSetComponent(bottom: true)
    }
    
    static var trailing: EdgeSetComponent {
        EdgeSetComponent(trailing: true)
    }
    
    static var none: EdgeSetComponent {
        EdgeSetComponent()
    }
}

extension EdgeSetComponent {
    var swiftUI: Edge.Set {
        var edges: Edge.Set = []
        if top {
            edges.insert(.top)
        }
        if leading {
            edges.insert(.leading)
        }
        if bottom {
            edges.insert(.bottom)
        }
        if trailing {
            edges.insert(.trailing)
        }
        return edges
    }
}
