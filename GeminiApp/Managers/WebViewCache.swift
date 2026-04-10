import SwiftUI
import WebKit
import Combine
import Cocoa

class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    private var activityToken: NSObjectProtocol?
    
    // YENİ: Bekleme süresi takibi için değişkenler
    private var lastActiveTime: Date = Date()
    private let idleThreshold: TimeInterval = 15 * 60 // 15 Dakika (Saniye cinsinden)
    
    private override init() {
        super.init()
        preventAppNap()
        
        // YENİ: Uygulamanın açılıp kapanmasını (odak değişimini) dinleyen observer'lar
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    // --- YENİ EKLENEN YÖNETİM FONKSİYONLARI ---
    
    @objc private func appDidResignActive() {
        // Popover kapandığında veya başka uygulamaya geçildiğinde saati kaydet
        lastActiveTime = Date()
    }
    
    @objc private func appDidBecomeActive() {
        // Popover açıldığında ne kadar süre geçtiğini hesapla
        let idleTime = Date().timeIntervalSince(lastActiveTime)
        
        // Eğer 15 dakikadan fazla uyumuşsa, zombi bağlantıyı temizlemek için sayfayı yenile
        if idleTime > idleThreshold {
            print("⏳ Uzun süre bekleme tespit edildi (\(Int(idleTime / 60)) dk). Zombi session yenileniyor...")
            webView?.reload()
        }
        
        // Saati sıfırla
        lastActiveTime = Date()
    }
    
    // ------------------------------------------
    
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
        print("⚠️ WebContent process terminated by macOS. Reloading...")
        webView.reload()
    }
    
    private func preventAppNap() {
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Keep WebView network connections and WebSockets alive"
        )
    }
}
