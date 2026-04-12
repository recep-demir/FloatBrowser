import SwiftUI
import WebKit
import Combine
import Cocoa

class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    private var activityToken: NSObjectProtocol?
    
    private var lastActiveTime: Date = Date()
    // Sohbetin çok sık yenilenmemesi için süreyi istersen buradan artırabilirsin (örneğin 10 dakika)
    private let idleThreshold: TimeInterval = 10 * 60
    
    private override init() {
        super.init()
        preventAppNap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidResignActive() {
        lastActiveTime = Date()
    }
    
    @objc private func appDidBecomeActive() {
        let idleTime = Date().timeIntervalSince(lastActiveTime)
        
        if idleTime > idleThreshold {
            print("⏳ Uzun bekleme sonrası sohbet korunarak yenileniyor...")
            forceReload()
        } else {
            // Sağlık kontrolü (Ping)
            webView?.evaluateJavaScript("document.readyState") { [weak self] (result, error) in
                if error != nil {
                    print("💀 Motor donmuş! Mevcut sayfa yeniden yükleniyor...")
                    self?.forceReload()
                }
            }
        }
        lastActiveTime = Date()
    }
    
    // --- SOHBETİ KORUYAN HARD RELOAD ---
    private func forceReload() {
        // Uygulamanın şu an bulunduğu tam adresi (sohbet ID'si dahil) alıyoruz
        if let currentURL = webView?.url {
            let request = URLRequest(url: currentURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            DispatchQueue.main.async {
                self.webView?.load(request)
            }
        } else if let baseURL = URL(string: "https://gemini.google.com") {
            // Eğer URL alınamazsa varsayılan adrese dön
            webView?.load(URLRequest(url: baseURL))
        }
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
        forceReload()
    }
    
    private func preventAppNap() {
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Keep WebView network connections and WebSockets alive"
        )
    }
}
