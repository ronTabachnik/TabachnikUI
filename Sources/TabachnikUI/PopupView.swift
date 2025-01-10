//
//  PopupView.swift
//
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import Foundation
import SwiftUI

public struct PopView: View {
    public var type: AlertType
    public var text: String
    public let withBackground: Bool
    public let visible: Bool
    public let backgroundColor: Color?
    
    public var body: some View {
        if visible {
            HStack(alignment: .center, spacing: 8) {
                if type == .loading {
                    ProgressView {
                        Text(type.text())
                    }
                        .frame(width: 30, height: 30)
                        .tint(type.color())
                } else {
                    Image(systemName: type.image())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(type.color())
                }
                Text(type == .loading ? type.text() : text)
                    .font(.system(size: 16, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .foregroundColor(type.color())
            }
            .padding()
            .background(withBackground ? backgroundColor != nil ? backgroundColor : Color.white : Color.clear)
            .cornerRadius(8)
            .overlay(
                Group {
                    if withBackground {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(type.color(), lineWidth: 2)
                    }
                }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    public init(type: AlertType = .error, text: String = "", withBackground: Bool = false, visible: Bool = true, backgroundColor: Color? = nil) {
        self.type = type
        self.text = text
        self.withBackground = withBackground
        self.visible = visible
        self.backgroundColor = backgroundColor
    }
}

public enum AlertType {
    case error
    case warning
    case success
    case loading
    
    func image() -> String {
        switch self {
        case .error: return "exclamationmark.triangle"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .loading: return ""
        }
    }
    
    func text() -> String {
        switch self {
        case .error: return "Error"
        case .warning: return "Warning"
        case .success: return "Success"
        case .loading: return "Loading..."
        }
    }
    
    func color() -> Color {
        switch self {
        case .error: return .red
        case .warning: return .orange
        case .success: return .green
        case .loading: return .blue
        }
    }
}

// MARK: - Popup View Extension
public extension View {
    func presentPopup(_ text: String, type: AlertType, isPresented: Bool, withBackground: Bool = true, backgroundColor: Color? = nil) -> some View {
        self.overlay(
            Group {
                if isPresented {
                    PopView(type: type, text: text, withBackground: withBackground, visible: isPresented, backgroundColor: backgroundColor)
                        .transition(.slide)
                        .animation(.easeInOut, value: isPresented)
//                        .shadow(radius: true ? 5 : 0)
                }
            }, alignment: .top
        )
    }
}

