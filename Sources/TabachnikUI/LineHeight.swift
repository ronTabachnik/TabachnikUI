//
//  File.swift
//  
//
//  Created by Ron Tabachnik on 15/08/2024.
//

import Foundation
import SwiftUI

extension View {
    public func lineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font, lineHeight: lineHeight))
    }
}

public struct FontWithLineHeight: ViewModifier {
    public let font: UIFont
    public let lineHeight: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
    
    public init(font: UIFont, lineHeight: CGFloat) {
        self.font = font
        self.lineHeight = lineHeight
    }
}
