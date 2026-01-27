import SwiftUI
import WebKit

struct AIMultiTabView: View {
    // Başlangıç servisi Gemini olsun
    @State private var selectedService: AIService = AIService.allServices.first!
    @State private var isPinned: Bool = false
    @State private var showPreferences: Bool = false
    
    // Servis listesi
    let services = AIService.allServices
    
    var body: some View {
        VStack(spacing: 0) { // Spacing 0 yapılarak aradaki boşluk alındı
            
            // --- ÜST HEADER (SADELEŞTİRİLMİŞ) ---
            HStack {
                // Sol taraf: Servis İkonları (Sekmeler)
                HStack(spacing: 15) {
                    ForEach(services) { service in
                        Button(action: {
                            selectedService = service
                        }) {
                            Image(service.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24) // Mini ikon boyutu
                                .opacity(selectedService.type == service.type ? 1.0 : 0.5) // Seçili değilse soluk
                                .scaleEffect(selectedService.type == service.type ? 1.1 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 10)
                
                Spacer()
                
                // Sağ taraf: Kontrol İkonları (Sadece Pin ve Ayarlar)
                HStack(spacing: 12) {
                    // Pin Butonu
                    Button(action: {
                        isPinned.toggle()
                        // Pencereyi sabitleme kodu buraya entegre edilebilir (WindowLevel vs.)
                        if let window = NSApplication.shared.windows.first {
                            window.level = isPinned ? .floating : .normal
                        }
                    }) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 16))
                            .foregroundColor(isPinned ? .blue : .gray)
                    }
                    .buttonStyle(.plain)
                    .help("Pencereyi Sabitle")
                    
                    // Ayarlar Butonu
                    Button(action: {
                        showPreferences = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .help("Ayarlar")
                }
                .padding(.trailing, 10)
            }
            .frame(height: 40) // Header yüksekliği sabitlendi
            .background(Color(NSColor.windowBackgroundColor)) // Arka plan rengi
            
            Divider() // İnce bir ayırıcı çizgi
            
            // --- WEB GÖRÜNÜMÜ ---
            // Kamera butonu ve başlıklar tamamen kaldırıldı
            ZStack {
                AIMultiWebView(url: selectedService.url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // Ayarlar penceresi
        .sheet(isPresented: $showPreferences) {
            PreferencesView()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

// WebView Bileşeni (Basit bir wrapper, eğer dosyanızda yoksa kullanabilirsiniz)
struct AIMultiWebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Otomatik oynatma ve diğer izinler
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        // User Agent ayarı (YouTube Music ve diğerleri için önemli)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}
