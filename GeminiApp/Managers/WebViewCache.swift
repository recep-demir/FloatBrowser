import SwiftUI
import WebKit
import Combine
import Cocoa

class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    private var activityToken: NSObjectProtocol?
    private var lastActiveTime: Date = Date()
    private let idleThreshold: TimeInterval = 10 * 60 // 10 Dakika sınırı
    
    private override init() {
        super.init()
        preventAppNap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidResignActive() {
        // Arkaya atıldığında saati kaydet
        lastActiveTime = Date()
    }
    
    @objc private func appDidBecomeActive() {
        let idleTime = Date().timeIntervalSince(lastActiveTime)
        
        // SADECE 10 dakikadan fazla beklediyse SESSİZCE VE YUMUŞAKÇA yenile
        if idleTime > idleThreshold {
            print("⏳ 10 dakikadan fazla beklendi. Mevcut sohbet yenileniyor...")
            webView?.reload() // Hard reload ve JS Ping kaldırıldı!
        }
        
        lastActiveTime = Date()
    }
    
    func getWebView() -> WKWebView {
        if let existing = webView {
            return existing
        }
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        config.allowsAirPlayForMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKPreferences()
        prefs.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = prefs
        
        let newWebView = WKWebView(frame: .zero, configuration: config)
        newWebView.navigationDelegate = self
        
        if let url = URL(string: "https://gemini.google.com") {
            newWebView.load(URLRequest(url: url))
        }
        
        // Stabil orijinal kimlik
        newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
        
        let currentZoom = PreferencesManager.shared.zoomLevel
        newWebView.pageZoom = CGFloat(currentZoom)
        newWebView.configuration.suppressesIncrementalRendering = false
        
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
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("⚠️ WebContent process öldü. Yenileniyor...")
        webView.reload()
    }
    
    private func preventAppNap() {
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Keep WebView network connections and WebSockets alive"
        )
    }
}
