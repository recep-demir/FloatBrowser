import SwiftUI
import WebKit
import Combine
import Cocoa // NSWorkspace için gerekli

// ENHANCEMENT: WKNavigationDelegate eklendi
class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    // ENHANCEMENT: App Nap'i engellemek için token
    private var activityToken: NSObjectProtocol?
    
    private override init() {
        super.init()
        preventAppNap() // Uygulama başlarken App Nap'i devre dışı bırak
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(macDidWake), name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    func getWebView() -> WKWebView {
        if let existing = webView {
            return existing
        }
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        let newWebView = WKWebView(frame: .zero, configuration: config)
        
        // ENHANCEMENT: Delegate ataması yapıldı
        newWebView.navigationDelegate = self
        
        if let url = URL(string: "https://gemini.google.com") {
            newWebView.load(URLRequest(url: url))
        }
        
        newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
        
        let currentZoom = PreferencesManager.shared.zoomLevel
        newWebView.pageZoom = CGFloat(currentZoom)
        
        self.webView = newWebView
        return newWebView
    }
    
    func updateZoom() {
        let level = PreferencesManager.shared.zoomLevel
        DispatchQueue.main.async {
            self.webView?.pageZoom = CGFloat(level)
        }
    }
    
    func clearCache() {
        webView = nil
    }
    
    // --- ENHANCEMENTS (GELİŞTİRMELER) ---
    
    // 1. WebContent Process ölürse/takılırsa otomatik yenile
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("⚠️ WebContent process terminated by macOS. Reloading...")
        webView.reload()
    }
    
    // 2. İşletim sisteminin uygulamayı derin uykuya almasını engelle
    private func preventAppNap() {
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Keep WebView network connections and WebSockets alive"
        )
    }
    
    // Mac uykudan uyandığında otomatik çalışır
        @objc func macDidWake() {
            print("🔄 Mac uyandı, ölü bağlantıları temizlemek için WebView yenileniyor...")
            DispatchQueue.main.async {
                self.webView?.reload()
            }
        }
}
