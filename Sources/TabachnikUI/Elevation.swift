//
//  SwiftUIView.swift
//  
//
//  Created by Ron Tabachnik on 15/08/2024.
//

import SwiftUI

public struct ElevationModifier: ViewModifier {
    let enabled: Bool
//    Hello this is an update
    public init(enabled: Bool) {
        self.enabled = enabled
    }
    
    public func body(content: Content) -> some View {
        if enabled {
            content
                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
        }else{
            content
        }
    }
}

extension View {
    public func elevated(_ enabled: Bool = true)->some View{
        self.modifier(ElevationModifier(enabled: enabled))
    }
}

    
