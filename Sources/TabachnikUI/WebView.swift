//
//  File.swift
//  TabachnikUI
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import SwiftUI
import Foundation
import WebKit
import UIKit

public struct WebViewWrapper: UIViewRepresentable {
    public let urlString: String

    public func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

// WebView struct with a custom navigation bar and embedded WebViewWrapper
@available(iOS 15.0, *)
public struct WebView<Content: View>: View {
    public let url: String
    public let header: () -> Content?

    public init(url: String, @ViewBuilder header: @escaping () -> Content? = { EmptyView() }) {
        self.url = url
        self.header = header
    }
    
    public var body: some View {
        VStack {
            header()
            WebViewWrapper(urlString: url)
                .navigationBarHidden(true)
        }
    }
}
