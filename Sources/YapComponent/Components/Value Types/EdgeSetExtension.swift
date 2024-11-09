import SwiftUI

extension Array where Element == Bool {
    var edgeSet: Edge.Set {
        switch count {
        case 0:
            return .all  // Default to all if empty
            
        case 1:
            return self[0] ? .all : []  // Single value affects all edges
            
        case 2:
            // First value is vertical (top/bottom), second is horizontal (leading/trailing)
            var edgeSet: Edge.Set = []
            if self[0] {
                edgeSet.insert(.top)
                edgeSet.insert(.bottom)
            }
            if self[1] {
                edgeSet.insert(.leading)
                edgeSet.insert(.trailing)
            }
            return edgeSet
            
        case 4:
            var edgeSet: Edge.Set = []
            if self[0] { edgeSet.insert(.top) }
            if self[1] { edgeSet.insert(.leading) }
            if self[2] { edgeSet.insert(.bottom) }
            if self[3] { edgeSet.insert(.trailing) }
            return edgeSet
            
        default:
            return .all  // Default to all for any other array size
        }
    }
}

extension Edge.Set {
    var array: [Bool] {
        if self == .all {
            return [true]  // Single value for all edges
        }
        
        if self.isEmpty {
            return [false]  // Single value for no edges
        }
        
        // Check if it's a vertical/horizontal combination
        let isVertical = contains(.top) && contains(.bottom) && !contains(.leading) && !contains(.trailing)
        let isHorizontal = !contains(.top) && !contains(.bottom) && contains(.leading) && contains(.trailing)
        
        if isVertical {
            return [true, false]  // Vertical only
        }
        if isHorizontal {
            return [false, true]  // Horizontal only
        }
        if contains(.top) && contains(.bottom) && contains(.leading) && contains(.trailing) {
            return [true, true]   // Both vertical and horizontal
        }
        
        // If no special case matches, return full 4-value array
        return [
            contains(.top),
            contains(.leading),
            contains(.bottom),
            contains(.trailing)
        ]
    }
}
