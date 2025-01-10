//
//  ImageScroller.swift
//
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import Foundation
import SwiftUI
import Kingfisher
import PhotosUI

public struct ImageScroller: View {
    public var images: [URL?]
    public let title: String
    public let selectedColor: Color
    public let unselectedColor: Color
    public let height: CGFloat
    public let radius: CGFloat
    public let buttonWidth: CGFloat
    public let buttonHeight: CGFloat
    public let navigate: (Int) -> Void
    private let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    @State private var selectedImageIndex: Int = 0

    public init(images: [URL?], title: String, selectedColor: Color = .black, unselectedColor: Color = .black.opacity(0.3), height: CGFloat = 200, radius: CGFloat = 12, buttonWidth: CGFloat = 35, buttonHeight: CGFloat = 8, navigate: @escaping (Int) -> Void) {
        self.images = images
        self.title = title
        self.unselectedColor = unselectedColor
        self.selectedColor = selectedColor
        self.navigate = navigate
        self.height = height
        self.radius = radius
        self.buttonWidth = buttonWidth
        self.buttonHeight = buttonHeight
    }

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedImageIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Button {
                        withAnimation(.snappy) {
                            navigate(index)
                        }
                    } label: {
                            KFImage(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                                .frame(height: height>500 ? height/2 : height)
                                .frame(maxWidth: .infinity)
                                .tag(index)
                                .cornerRadius(radius)
                    }
                }
            }
            .frame(height: height>500 ? height/2 : height)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack {
                ForEach(0..<images.count, id: \.self) { index in
                    Capsule()
                        .fill(selectedImageIndex == index ? selectedColor : unselectedColor)
                        .frame(width: buttonWidth, height: buttonHeight)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                selectedImageIndex = index
                            }
                        }
                }
            }
                .padding(.top, -20)
            
        }
        .onReceive(timer) { _ in
            withAnimation(.snappy) {
                selectedImageIndex = (selectedImageIndex + 1) % images.count
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

