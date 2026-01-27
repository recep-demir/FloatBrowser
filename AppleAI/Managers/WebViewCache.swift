import SwiftUI
import WebKit
import AVFoundation
import Combine

class WebViewStore: NSObject, ObservableObject {
    static let shared = WebViewStore()
    
    // 'private' ifadesi kaldırıldı, artık diğer dosyalardan erişilebilir
    @Published var webViews: [String: WKWebView] = [:]
    @Published var loadingStates: [String: Bool] = [:]
    
    override init() {
        super.init()
    }
    
    func getWebView(for service: AIService) -> WKWebView {
        if let webView = webViews[service.id] {
            return webView
        }
        
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // User Agent ayarı (YouTube Music ve diğerleri için önemli)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        webView.navigationDelegate = self
        
        // İlk yükleme
        let request = URLRequest(url: service.url)
        webView.load(request)
        
        webViews[service.id] = webView
        return webView
    }
    
    func clearCache(for serviceId: String) {
        webViews.removeValue(forKey: serviceId)
    }
    
    func injectAudioStopScript() {
        // Tüm webview'lerde sesi durdurmak için script çalıştır
        for (_, webView) in webViews {
            let script = """
            var videos = document.getElementsByTagName('video');
            var audios = document.getElementsByTagName('audio');
            for(var i=0; i<videos.length; i++) videos[i].pause();
            for(var i=0; i<audios.length; i++) audios[i].pause();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

// WKNavigationDelegate uyumluluğu
extension WebViewStore: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Yükleme tamamlandığında yapılacak işlemler (boş bırakılabilir)
    }
}
