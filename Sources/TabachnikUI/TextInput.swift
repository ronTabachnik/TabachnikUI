//
//  TextInput.swift
//
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import Foundation
import SwiftUI

public struct TextInput: View {
    public let title: String
    private let mandatory: Bool
    private let secureEntry: Bool
    private let borderColor: Color
    private let borderRadius: CGFloat
    private let showFullBorder: Bool
    private let showOverlayText: Bool
    private let font: UIFont
    private let fontHeight: CGFloat
    private let borderHeight: CGFloat
    private let keyboardType: UIKeyboardType
    private let isTextBox: Bool
    private let isSelection: Bool
    private let placeholder: String
    @State private var isFocused: Bool = false
    @State private var isVisible: Bool = false
    @Binding private var text: String
    
    public init(
        _ title: String,
        text: Binding<String>,
        mandatory: Bool = false,
        secureEntry: Bool = false,
        keyboardType: UIKeyboardType = .default,
        borderColor: Color = .black,
        borderRadius: CGFloat = 8,
        showFullBorder: Bool = true,
        font: UIFont,
        fontHeight: CGFloat = 20,
        borderHeight: CGFloat = 50,
        showOverlayText: Bool = true,
        isTextBox: Bool = false,
        isSelection: Bool = false,
        placeholder: String = ""
        
    ){
        self.title = title
        self._text = text
        self.mandatory = mandatory
        self.secureEntry = secureEntry
        self.keyboardType = keyboardType
        self.borderColor = borderColor
        self.borderRadius = borderRadius
        self.showFullBorder = showFullBorder
        self.font = font
        self.fontHeight = fontHeight
        self.borderHeight = borderHeight
        self.showOverlayText = showOverlayText
        self.isTextBox = isTextBox
        self.isSelection = isSelection
        self.placeholder = placeholder
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            // Floating label
            HStack(spacing: 0) {
                Text(" \(title) ")
                    .foregroundColor(Color(.placeholderText))
                if mandatory {
                    Text("* ")
                        .foregroundColor(.red)
                }
            }
            .font(isFocused || !text.isEmpty ? .system(size: 12) : .system(size: 14))
            .padding(.leading, 16)
            .foregroundColor(borderColor)
            .background(Color.clear)
            .offset(y: showOverlayText ? isFocused || !text.isEmpty ? showFullBorder ? -(borderHeight/2) - 10 : -(borderHeight/2) : 0 : 0)
            .opacity(!text.isEmpty ? showOverlayText ? 1 : 0 : 1 )
            .animation(.easeInOut(duration: 0.3), value: isFocused || !text.isEmpty)
            
            HStack {
                TextFieldView()
                    .padding(.leading, isTextBox ? 0 : 16)
                    .padding(.trailing, secureEntry ? 50 : 0)
                    .autocorrectionDisabled(true)
                    .keyboardType(keyboardType)
                    .foregroundColor(borderColor)
                    .lineHeight(font: font, lineHeight: fontHeight)
                    .frame(height: borderHeight)
                    .background(Color.clear)
                    .onTapGesture {
                        self.isFocused = true
                    }
                    .onAppear {
                        self.isFocused = false
                    }
                
                if secureEntry && !text.isEmpty {
                    Button(action: {
                        isVisible.toggle()
                    }) {
                        Image(systemName: isVisible ? "eye.slash" : "eye")
                            .resizable()
                            .scaledToFit()
                            .frame(width: borderHeight/2 > 35 ? 35 : borderHeight/2, height: borderHeight/2 > 35 ? 35 : borderHeight/2)
                            .foregroundColor(isFocused ? borderColor.opacity(0.5) : borderColor)
                    }
                    .padding(.horizontal, 8)
                } else if isSelection {
                    Image("Chevron")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(Angle(degrees: -90))
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, 8)
                }
                else if !text.isEmpty && isFocused {
                    Button(action: {
                        text = ""
                        self.isFocused = isTextBox ? false : true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: borderHeight/2 > 35 ? 35 : borderHeight/2, height: borderHeight/2 > 35 ? 35 : borderHeight/2)
                            .foregroundColor(Color(.placeholderText))
                    }
                    .padding(.horizontal, 8)
                }
            }
            .cornerRadius(borderRadius)
            .overlay(
                Group {
                    if showFullBorder {
                        RoundedRectangle(cornerRadius: borderRadius)
                            .stroke(borderColor.opacity(0.3), lineWidth: 1)
                            .frame(height: borderHeight)
                    } else {
                        Rectangle()
                            .fill(borderColor.opacity(0.3))
                            .frame(height: 1)
                            .padding(.top, borderHeight - 1)
                    }
                }
            )
        }
    }
    
    // View returning TextField or SecureField
    private func TextFieldView() -> some View {
        Group {
            if secureEntry && !isVisible {
                SecureField("", text: $text)
                    .onTapGesture {
                        self.isFocused = true
                    }
            } else if isTextBox {
                TextEditor(text: $text)
                    .frame(maxWidth: .infinity)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Dismiss Keyboard") {
                                UIApplication.shared.endEditing()
                            }
                        }
                    }
                    .frame(height: borderHeight)
                    .cornerRadius(borderRadius)
                    .placeholder(when: text.isEmpty, alignment: .topLeading , placeholder: {
                        Text(placeholder)
                            .opacity(0.7)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                    })
                    .foregroundColor(borderColor)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor,lineWidth: 1)
                    )
            } else {
                TextField("", text: $text, onEditingChanged: { editing in
                    self.isFocused = editing
                })
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    public func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        self
            .overlay(
                placeholder().opacity(shouldShow ? 1 : 0),
                alignment: alignment
            )
    }
}
