import SwiftUI
import WebKit

struct AIWebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> NSView {
        // 1. Bir Konteyner (Kutu) oluşturuyoruz
        let containerView = NSView()
        containerView.wantsLayer = true
        
        // 2. Cache'den WebView'i al
        let serviceId: String
        if url.absoluteString.contains("gemini") { serviceId = "gemini" }
        else if url.absoluteString.contains("chatgpt") { serviceId = "chatgpt" }
        else { serviceId = "youtubeMusic" }
        
        let webView = WebViewCache.shared.getWebView(forId: serviceId, url: url)
        
        // 3. Eski pencereden (varsa) kopar
        webView.removeFromSuperview()
        
        // 4. Konteynera ekle
        containerView.addSubview(webView)
        
        // 5. AUTO LAYOUT (Siyah Ekranı Çözen Büyü)
        // WebView'e "Konteynerin her kenarına yapış" diyoruz.
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Not: nsView artık bizim containerView'imiz.
        // İçindeki WebView'i bulalım.
        guard let webView = nsView.subviews.first as? WKWebView else { return }
        
        // URL kontrolü ve yükleme
        if let currentHost = webView.url?.host, currentHost != url.host {
            webView.load(URLRequest(url: url))
        }
        
        // Render motorunu tetiklemek için ufak bir gecikmeli güncelleme
        DispatchQueue.main.async {
            webView.needsLayout = true
        }
    }
}
