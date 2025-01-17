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
    @Binding public var originalUrl: URL?

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        context.coordinator.originalUrl = URL(string: urlString) // Save the original URL
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString), url != context.coordinator.currentUrl {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        var originalUrl: URL?
        var currentUrl: URL?

        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            currentUrl = webView.url
        }

        func navigateToOriginalUrl(in webView: WKWebView) {
            if let originalUrl = originalUrl {
                let request = URLRequest(url: originalUrl)
                webView.load(request)
            }
        }
    }
}

@available(iOS 15.0, *)
public struct WebView<Content: View>: View {
    public let url: String
    public let header: () -> Content?
    @State private var originalUrl: URL?

    public init(url: String, @ViewBuilder header: @escaping () -> Content? = { EmptyView() }) {
        self.url = url
        self.header = header
    }
    
    public var body: some View {
        VStack {
            HStack {
                if let originalUrl = originalUrl {
                    Button(action: {
                        NotificationCenter.default.post(
                            name: Notification.Name("NavigateToOriginalUrl"),
                            object: originalUrl
                        )
                    }) {
                        Text("Go to Original URL")
                    }
                }
                Spacer()
            }
            .padding()

            WebViewWrapper(urlString: url, originalUrl: $originalUrl)
                .navigationBarHidden(true)
        }
    }
}
