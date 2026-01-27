import SwiftUI
import WebKit
import AVFoundation
import Combine // <-- BU EKLENDİ (ObservableObject hatalarının çözümü)

// Global WebView Cache
class WebViewCache: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    static let shared = WebViewCache()
    
    @Published private var webViews: [String: WKWebView] = [:]
    @Published var loadingStates: [String: Bool] = [:]
    @Published var isFilePickerActive: Bool = false
    
    // NOT: processPool satırları silindi çünkü macOS 12+ artık buna ihtiyaç duymuyor.
    
    private override init() {
        super.init()
        preloadWebViews()
        
        DispatchQueue.main.async {
            self.requestMicrophonePermission()
        }
    }
    
    private func preloadWebViews() {
        for service in AIService.allCases {
            if webViews[service.id] == nil {
                let webView = createWebView(for: service)
                webViews[service.id] = webView
            }
        }
    }
    
    func getWebView(for service: AIService) -> WKWebView {
        if let webView = webViews[service.id] {
            return webView
        }
        let webView = createWebView(for: service)
        webViews[service.id] = webView
        return webView
    }
    
    private func createWebView(for service: AIService) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        // config.processPool satırı SİLİNDİ (Uyarı çözümü)
        
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "mediaPermission")
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Şeffaflık ayarı
        webView.setValue(false, forKey: "drawsBackground")
        
        // Google Login vb. için User Agent
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
        
        if let url = URL(string: service.url.absoluteString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    // MARK: - Delegates
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Yükleme bitti
    }
    
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        isFilePickerActive = true
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
        openPanel.canChooseDirectories = parameters.allowsDirectories
        
        openPanel.begin { result in
            self.isFilePickerActive = false
            if result == .OK {
                completionHandler(openPanel.urls)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    @available(macOS 12.0, *)
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // JS mesajları
    }
    
    func requestMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
        case .denied:
            print("Mikrofon izni reddedildi")
        default:
            break
        }
    }
}

struct AIWebView: NSViewRepresentable {
    let url: URL
    let service: AIService
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WebViewCache.shared.getWebView(for: service)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url?.host != url.host {
             nsView.load(URLRequest(url: url))
        }
    }
}
