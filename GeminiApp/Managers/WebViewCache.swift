import SwiftUI
import WebKit
import Combine
import Cocoa

class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewCache()
    private var webView: WKWebView?
    
    private var activityToken: NSObjectProtocol?
    
    private var lastActiveTime: Date = Date()
    // BEKLEME SÜRESİ 3 DAKİKAYA DÜŞÜRÜLDÜ
    private let idleThreshold: TimeInterval = 3 * 60
    
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
            print("⏳ 3 dakikadan fazla beklendi. Hard Reload yapılıyor...")
            forceReload()
        } else {
            // YENİ: KISA SÜRELİ BEKLEMELERDE "PING" (SAĞLIK KONTROLÜ)
            // Eğer sayfa donmuşsa JavaScript cevap veremez. Cevap gelmezse anında zorla yenile.
            webView?.evaluateJavaScript("document.readyState") { [weak self] (result, error) in
                if error != nil {
                    print("💀 WebKit JavaScript motoru donmuş! Hard Reload yapılıyor...")
                    self?.forceReload()
                }
            }
        }
        lastActiveTime = Date()
    }
    
    // YENİ: SOFT RELOAD YERİNE HARD RESET FONKSİYONU
    private func forceReload() {
        // Normal .reload() işlemi donmuş bir WKWebView'da sıraya girer ama çalışmaz.
        // Bunun yerine, URL'i Cache'i (Önbelleği) hiçe sayarak en baştan yükletiyoruz.
        if let url = URL(string: "https://gemini.google.com") {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            DispatchQueue.main.async {
                self.webView?.load(request)
            }
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
        print("⚠️ WebContent process terminated by macOS. Reloading...")
        forceReload() // Zorla kapatılmalarda da Hard Reset at
    }
    
    private func preventAppNap() {
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Keep WebView network connections and WebSockets alive"
        )
    }
}
