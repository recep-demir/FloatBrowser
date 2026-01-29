import SwiftUI
import WebKit

struct AIWebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> NSView {
        // 1. Boş bir taşıyıcı (Container) oluştur
        let containerView = NSView()
        containerView.wantsLayer = true
        
        // İlk yüklemeyi yap
        updateContent(in: containerView, for: url)
        
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // URL değiştiğinde (Sekme değiştiğinde) içeriği güncelle
        updateContent(in: nsView, for: url)
    }
    
    // --- YENİ MANTIK: GÜNCELLEME DEĞİL, DEĞİŞTİRME (SWAP) ---
    private func updateContent(in container: NSView, for url: URL) {
        // 1. URL'ye göre hangi servisin WebView'ine ihtiyacımız olduğunu bul
        let serviceId: String
        if url.absoluteString.contains("gemini") { serviceId = "gemini" }
        else if url.absoluteString.contains("chatgpt") { serviceId = "chatgpt" }
        else { serviceId = "youtubeMusic" }
        
        // 2. Cache'den o servise ait WebView'i getir (Hafızada canlı duruyor)
        let targetWebView = WebViewCache.shared.getWebView(forId: serviceId, url: url)
        
        // 3. Şu an ekranda bir WebView var mı?
        if let currentWebView = container.subviews.first as? WKWebView {
            // Eğer ekrandaki zaten hedeflediğimiz ise hiçbir şey yapma.
            // (Bu, gereksiz sayfa yenilenmesini engeller)
            if currentWebView == targetWebView {
                return
            }
            
            // Eğer farklıysa, eskiyi ekrandan kaldır (Ama hafızadan silinmez, Cache tutar)
            currentWebView.removeFromSuperview()
        }
        
        // 4. Yeni WebView'i hazırla
        // Eğer başka bir penceredeyse (örn: Unpin yaparken) oradan kopar
        targetWebView.removeFromSuperview()
        
        // 5. Konteynera ekle
        container.addSubview(targetWebView)
        
        // 6. Auto Layout ile pencereye tam oturt (Siyah ekranı önler)
        targetWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            targetWebView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            targetWebView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            targetWebView.topAnchor.constraint(equalTo: container.topAnchor),
            targetWebView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // 7. Çizimi tetikle
        targetWebView.needsLayout = true
    }
}
