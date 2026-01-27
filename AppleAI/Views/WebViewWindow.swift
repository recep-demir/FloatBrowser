import SwiftUI
import WebKit
import Combine

struct WebViewWindow: View {
    @StateObject private var webViewCache = WebViewCache.shared
    @State private var currentService: AIService = .gemini // Varsayılan açılış
    @State private var isPinned: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- Header Kısmı ---
            HStack(spacing: 16) {
                
                // 1. Sabitleme İkonu
                Button(action: {
                    isPinned.toggle()
                    if let window = NSApp.windows.first(where: { $0.contentView?.isKind(of: NSHostingView<WebViewWindow>.self) == true }) {
                        window.level = isPinned ? .floating : .normal
                    }
                }) {
                    Image(systemName: isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 14))
                        .foregroundColor(isPinned ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
                .help("Pencereyi Sabitle")
                
                Spacer()
                
                // 2. Servis İkonları
                ForEach([AIService.gemini, AIService.chatgpt, AIService.youtubeMusic], id: \.self) { service in
                    Button(action: {
                        currentService = service
                    }) {
                        // İkonu belirle
                        Group {
                            if service == .youtubeMusic {
                                // YouTube Music için sistem ikonu
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            } else {
                                // Diğerleri için Asset'ten resim
                                Image(service.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .opacity(currentService == service ? 1.0 : 0.4) // Seçili değilse soluk
                        .shadow(radius: currentService == service ? 2 : 0)
                    }
                    .buttonStyle(.plain)
                    .help(service.name)
                }
                
                Spacer()
                
                // 3. Ayarlar İkonu
                Button(action: {
                     // Ayarları açma komutu
                     if let url = URL(string: "floatbrowser://preferences") {
                         NSWorkspace.shared.open(url)
                     }
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)
            
            // --- WebView Kısmı ---
            // service.url diyerek URL'i de gönderiyoruz
            AIWebView(url: currentService.url, service: currentService)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 350, minHeight: 450)
    }
}
