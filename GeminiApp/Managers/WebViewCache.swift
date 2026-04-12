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
        
        // YENİ: SADECE BİR KEREYE MAHSUS BOZUK ÖNBELLEĞİ SİLER
        clearCorruptedDataOnce()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    // --- YENİ: OTOMATİK ÖNBELLEK TEMİZLEYİCİ ---
    private func clearCorruptedDataOnce() {
        let hasCleared = UserDefaults.standard.bool(forKey: "hasClearedZombieCache_v2")
        if !hasCleared {
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) {
                print("🧹 Önceki denemelerden kalan bozuk Google önbelleği tamamen temizlendi.")
                // Temizlendiğini kaydet, bir daha asla silme
                UserDefaults.standard.set(true, forKey: "hasClearedZombieCache_v2")
            }
        }
    }
    
    @objc private func appDidResignActive() {
        lastActiveTime = Date()
    }
    
    @objc private func appDidBecomeActive() {
        let idleTime = Date().timeIntervalSince(lastActiveTime)
        
        if idleTime > idleThreshold {
            print("⏳ 10 dakikadan fazla beklendi. Mevcut sohbet yenileniyor...")
            webView?.reload()
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
        
        // DİKKAT: customUserAgent TAMAMEN KALDIRILDI!
        // macOS'in kendi yerel Safari motoruyla bağlanmasını sağlıyoruz, bu Error 13'ü engeller.
        
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
