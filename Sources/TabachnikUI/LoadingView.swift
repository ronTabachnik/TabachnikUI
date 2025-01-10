//
//  File.swift
//  
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import Foundation
import SwiftUI

public struct LoadingView: View {
    public let showText: Bool
    @State private var dots = ""
    @State private var isAnimating = false
    public let backgroundColor: Color
    public let tintColor: Color
    private let dotAnimation = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let rotationAnimation = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)

    public var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0.0, to: 0.7)
                    .stroke(lineWidth: 4)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .animation(rotationAnimation, value: isAnimating)
            }

            if showText {
                Text("Loading\(dots)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onReceive(dotAnimation) { _ in
                        if dots.count < 3 {
                            dots += "."
                        } else {
                            dots = ""
                        }
                    }
            }
        }
        .frame(width: 65)
        .onAppear {
            isAnimating = true
        }
    }

    public init(showText: Bool = true, backgroundColor: Color = .gray.opacity(0.3), tintColor: Color = .blue) {
        self.showText = showText
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
    }
}
