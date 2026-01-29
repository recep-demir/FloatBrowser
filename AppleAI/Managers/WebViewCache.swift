import SwiftUI
import WebKit
import Combine

class WebViewCache: NSObject, ObservableObject {
    static let shared = WebViewCache()
    
    @Published private var webViews: [String: WKWebView] = [:]
    
    private override init() {
        super.init()
    }
    
    func getWebView(forId id: String, url: URL) -> WKWebView {
        if let existing = webViews[id] {
            return existing
        }
        
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()
        
        // JAVASCRIPT: "BEKÇİ" MODU (Brute Force Fix)
        let jsSource = """
        (function() {
            // 1. YouTube Music'in butonlarını bulup tıklayan fonksiyonlar
            function next() { document.querySelector('.next-button')?.click(); }
            function prev() { document.querySelector('.previous-button')?.click(); }
            function toggle() { document.querySelector('.play-pause-button')?.click(); }

            // 2. Media Session API'sini Hackle
            // Tarayıcının orijinal fonksiyonunu yedekle
            const originalSetActionHandler = navigator.mediaSession.setActionHandler.bind(navigator.mediaSession);

            // Fonksiyonu kendi versiyonumuzla değiştir (Override)
            navigator.mediaSession.setActionHandler = function(action, handler) {
                // Eğer site "seek" (15sn atlama) eklemeye çalışırsa ENGELLE
                if (action === 'seekbackward' || action === 'seekforward') {
                    return; // Hiçbir şey yapma, isteği yut.
                }
                // Diğer istekleri (Play, Pause, Next) olduğu gibi geçir
                originalSetActionHandler(action, handler);
            };

            // 3. Bizim İstediğimiz Butonları Zorla (Sürekli Döngü)
            function forceMediaControls() {
                if (!navigator.mediaSession) return;

                // 15sn butonlarını NULL yaparak sistemden sil
                originalSetActionHandler('seekbackward', null);
                originalSetActionHandler('seekforward', null);

                // İleri / Geri butonlarını zorla tanımla
                originalSetActionHandler('previoustrack', prev);
                originalSetActionHandler('nexttrack', next);
                
                // Oynat / Durdur
                originalSetActionHandler('play', toggle);
                originalSetActionHandler('pause', toggle);
            }

            // Sayfa yüklendiğinde ve her 1 saniyede bir bunu tekrarla
            // YouTube Music bazen kendi ayarlarını yeniler, biz de onunkini ezeriz.
            forceMediaControls();
            setInterval(forceMediaControls, 1000);
        })();
        """

        // Scripti sayfa başlar başlamaz ve bittiğinde enjekte et
        let userScript = WKUserScript(source: jsSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // Masaüstü Chrome gibi davran (En iyi medya desteği için)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        
        webViews[id] = webView
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func clearCache() {
        webViews.removeAll()
    }
}
