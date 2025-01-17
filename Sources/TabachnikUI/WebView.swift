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

public class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var parent: WebViewWrapper

    init(parent: WebViewWrapper) {
        self.parent = parent
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}

public struct WebViewWrapper: UIViewRepresentable {
    public let urlString: String

    public func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(parent: self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

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
