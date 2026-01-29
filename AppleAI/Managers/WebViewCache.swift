import SwiftUI
import WebKit
import Combine

class WebViewCache: NSObject, ObservableObject {
    static let shared = WebViewCache()
    
    @Published private var webViews: [String: WKWebView] = [:]
    
    private override init() {
        super.init()
    }
    
    // ID ve URL ile WebView getir
    func getWebView(forId id: String, url: URL) -> WKWebView {
        if let existing = webViews[id] {
            return existing
        }
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        // Allow inline playback on iOS when available, and allow autoplay by not requiring user action
        #if os(iOS)
        config.allowsInlineMediaPlayback = true
        #endif
        if #available(iOS 10.0, macOS 10.12, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        webViews[id] = webView
        
        // Cache oluşturulurken yükle
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func clearCache() {
        webViews.removeAll()
    }
}
