import SwiftUI
import WebKit
import Combine

class WebViewCache: NSObject, ObservableObject {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    private override init() {
        super.init()
    }
    
    func getWebView() -> WKWebView {
        if let existing = webView {
            return existing
        }
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        let newWebView = WKWebView(frame: .zero, configuration: config)
        
        // Gemini URL
        if let url = URL(string: "https://gemini.google.com") {
            newWebView.load(URLRequest(url: url))
        }
        
        // Safari User Agent (En sorunsuz olanı)
        newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
        
        // İlk açılışta kayıtlı zoom seviyesini uygula
        let currentZoom = PreferencesManager.shared.zoomLevel
        newWebView.pageZoom = CGFloat(currentZoom)
        
        self.webView = newWebView
        return newWebView
    }
    
    // YENİ: Zoom güncelleme komutu
    // Bu fonksiyon PreferencesManager tarafından çağrılacak
    func updateZoom() {
        let level = PreferencesManager.shared.zoomLevel
        DispatchQueue.main.async {
            self.webView?.pageZoom = CGFloat(level)
        }
    }
    
    func clearCache() {
        webView = nil
    }
}
