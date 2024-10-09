import SwiftUI

public struct AlignmentComponent: Equatable {
    var horizontal: HorizontalAlignmentComponent = .center
    var vertical: VerticalAlignmentComponent = .center
    
    public init(horizontal: HorizontalAlignmentComponent = .center, vertical: VerticalAlignmentComponent = .center) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public init() {}
    
    static var topLeading: AlignmentComponent { .init(horizontal: .leading, vertical: .top) }
    static var top: AlignmentComponent { .init(horizontal: .center, vertical: .top) }
    static var topTrailing: AlignmentComponent { .init(horizontal: .trailing, vertical: .top) }
    static var leading: AlignmentComponent { .init(horizontal: .leading, vertical: .center) }
    static var center: AlignmentComponent { .init(horizontal: .center, vertical: .center) }
    static var trailing: AlignmentComponent { .init(horizontal: .trailing, vertical: .center) }
    static var bottomLeading: AlignmentComponent { .init(horizontal: .leading, vertical: .bottom) }
    static var bottom: AlignmentComponent { .init(horizontal: .center, vertical: .bottom) }
    static var bottomTrailing: AlignmentComponent { .init(horizontal: .trailing, vertical: .bottom) }
    
}

extension AlignmentComponent: AutomaticComponentConvertible {
//    public init(_ component: Component) {
//        self.horizontal = component.props["horizontal"].map(decodeComponent(_:)) as? HorizontalAlignmentComponent ?? .center
//        self.vertical = component.props["vertical"].map(decodeComponent(_:)) as? VerticalAlignmentComponent ?? .center
//    }
}

extension AlignmentComponent {
    var swiftUI: Alignment {
        Alignment(horizontal: horizontal.swiftUI, vertical: vertical.swiftUI)
    }
}
