//
//  ContainerView.swift
//  YapRenderer
//
//  Created by Ollie Wagner on 9/23/24.
//

import SwiftUI
import YapComponent

struct ContainerView: View {
    
    enum Name: String, CaseIterable {
        case VStack
        case HStack
        case ZStack
        case ScrollView
        case List
    }
    
    let directive: Directive
    
    init(_ directive: Directive) {
        self.directive = directive
    }
    
    var props: Props {
        Props(directive)
    }
    
    var body: some View {
        switch Name(rawValue: directive.type) {
        case .VStack:
            VStack(alignment: props.alignment ?? .center, spacing: props.spacing) {
                children
            }
        case .HStack:
            HStack(alignment: props.alignment ?? .center, spacing: props.spacing) {
                children
            }
        case .ZStack:
            ZStack(alignment: props.alignment ?? .center) {
                children
            }
        case .ScrollView:
            ScrollView {
                children
            }
        case .List:
            List {
                children
            }
        case .none:
            EmptyView()
        }
    }
    
    var children: ComponentView {
        ComponentView(directive.children)
    }
}
