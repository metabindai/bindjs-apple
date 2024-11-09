import SwiftUI

struct PaddingComponent: AutomaticComponentConvertible {
    var edges: [Bool] = []
    var insets: [Double]? = nil
    var rawValue: Double?
    
    static var keyPaths: [(String, AnyKeyPath)] {
        [
            ("edges", \Self.edges),
            ("insets", \Self.insets),
            ("rawValue", \Self.rawValue)
            
        ]
    }
}

extension PaddingComponent: ViewModifier {

    func body(content: Content) -> some View {
        content
            .modifier(_PaddingLayout(edges: edges.edgeSet, insets: rawValue.map { [$0].edgeInsets } ?? insets?.edgeInsets))
    }
}



extension Array where Element == Double {
    var edgeInsets: EdgeInsets? {
        switch count {
        case 0:
            return nil
            
        case 1:
            // Single value applies to all edges
            return EdgeInsets(top: self[0], leading: self[0], bottom: self[0], trailing: self[0])
            
        case 2:
            // First value is vertical (top/bottom), second is horizontal (leading/trailing)
            return EdgeInsets(
                top: self[0],
                leading: self[1],
                bottom: self[0],
                trailing: self[1]
            )
            
        case 4:
            return EdgeInsets(
                top: self[0],
                leading: self[1],
                bottom: self[2],
                trailing: self[3]
            )
            
        default:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }
}


extension EdgeInsets {
    var array: [Double] {
        // Check if all values are equal
        if top == leading && top == bottom && top == trailing {
            return [top]  // Single value for all edges
        }
        
        // Check if it's vertical/horizontal pattern
        if top == bottom && leading == trailing {
            return [top, leading]  // [vertical, horizontal]
        }
        
        // Return full 4-value array
        return [top, leading, bottom, trailing]
    }
}
