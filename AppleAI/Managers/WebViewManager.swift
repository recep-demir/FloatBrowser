import Foundation
import WebKit
import Combine

class WebViewManager: ObservableObject {
    static let shared = WebViewManager()
    
    // Aktif olan WebView'i burada tutabiliriz veya sadece URL yönetimi yapabiliriz
    @Published var currentURL: URL?
    
    // WebView referansını tutmak için (reload vs. işlemleri için)
    var webView: WKWebView?
    
    private init() {}
    
    func load(url: URL) {
        self.currentURL = url
        
        // Eğer bir WebView instance'ımız varsa doğrudan yükle
        if let webView = webView {
            let request = URLRequest(url: url)
            DispatchQueue.main.async {
                webView.load(request)
            }
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.webView?.reload()
        }
    }
    
    func goBack() {
        if let webView = webView, webView.canGoBack {
            webView.goBack()
        }
    }
    
    func goForward() {
        if let webView = webView, webView.canGoForward {
            webView.goForward()
        }
    }
}
