import SwiftUI
import WebKit

struct CompactChatView: View {
    @State private var selectedService: AIService = aiServices[0] // Varsayılan olarak Gemini
    @StateObject private var webViewCache = WebViewStore.shared
    @StateObject private var proManager = ProManager.shared // Pro özellikleri aktif

    var body: some View {
        VStack(spacing: 0) { // Spacing 0 yapılarak dikey boşluk azaltıldı
            // Üst Başlık ve Servis Seçici
            HStack(spacing: 12) {
                // Uygulama İkonu ve Pin (İsteğe bağlı, sol tarafta)
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Servis İkonları (İsimler kaldırıldı, sadece ikonlar)
                ForEach(aiServices) { service in
                    Button(action: {
                        selectedService = service
                    }) {
                        Image(systemName: service.iconName) // Sadece ikon
                            .font(.system(size: 16, weight: .medium)) // Mini ikon boyutu
                            .foregroundColor(selectedService.id == service.id ? .blue : .gray)
                            .padding(6)
                            .background(selectedService.id == service.id ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(service.name) // Üzerine gelince isim görünsün
                }
                
                Spacer()
                
                // Sağ taraftaki ayarlar/refresh butonları (Kamera kaldırıldı)
                Button(action: {
                    if let webView = webViewCache.webViews[selectedService.id] {
                        webView.reload()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4) // Dikey boşluk çok azaltıldı (Modern görünüm)
            .background(VisualEffectBlur(material: .headerView, blendingMode: .withinWindow))
            
            Divider()
            
            // WebView Alanı
            AIWebView(url: selectedService.url, service: selectedService)
                .id(selectedService.id) // Servis değişince view'i yenile
        }
        .frame(minWidth: 350, minHeight: 400)
    }
}

// Blur efekti için yardımcı yapı
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
