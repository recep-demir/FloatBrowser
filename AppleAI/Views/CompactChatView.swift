import SwiftUI
import WebKit

struct CompactChatView: View {
    @ObservedObject var menuManager: MenuBarManager
    @ObservedObject var prefs = PreferencesManager.shared
    
    @State private var selectedService: AIService = .gemini
    @StateObject private var webViewManager = WebViewManager.shared
    
    @AppStorage("lastSelectedService") private var storedServiceRawValue: String = AIService.gemini.rawValue
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Header ---
            HStack(spacing: 16) {
                // PIN Butonu
                Button(action: { menuManager.togglePin() }) {
                    Image(systemName: menuManager.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 13))
                        .foregroundColor(menuManager.isPinned ? .accentColor : .gray)
                        .padding(4)
                        .background(menuManager.isPinned ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 12)
                
                Spacer()
                
                // Servis İkonları
                HStack(spacing: 20) {
                    ForEach(AIService.allCases.filter { prefs.isServiceEnabled($0) }) { service in
                        Button(action: {
                            switchService(to: service)
                        }) {
                            Group {
                                if service.isSystemIcon {
                                    Image(systemName: service.iconName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image(service.iconName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .frame(width: 18, height: 18)
                            .foregroundColor(selectedService == service ? Color.accentColor : Color.gray)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedService == service ? Color.gray.opacity(0.1) : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                // Ayarlar Butonu
                Button(action: { menuManager.openSettings() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .opacity(0.7)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 12)
            }
            .frame(height: 38)
            .background(VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow))
            .overlay(
                Rectangle().frame(height: 0.5).foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
            
            // --- WebView ---
            // Konteyner yapısı (AIWebView zaten kendi içinde handle ediyor ama burası temiz kalsın)
            AIWebView(url: selectedService.url)
        }
        .frame(minWidth: 350, minHeight: 500)
        .onAppear {
            if let saved = AIService(rawValue: storedServiceRawValue), prefs.isServiceEnabled(saved) {
                selectedService = saved
            } else if let first = AIService.allCases.first(where: { prefs.isServiceEnabled($0) }) {
                selectedService = first
            }
            webViewManager.load(url: selectedService.url)
        }
        // YENİ ÖZELLİK: Sinyali Dinle ve Müziğe Geç
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToYouTubeMusic"))) { _ in
            switchService(to: .youtubeMusic)
        }
    }
    
    // Yardımcı Fonksiyon: Servis Değiştirme
    private func switchService(to service: AIService) {
        // Eğer o servis ayarlardan kapalıysa zorla açamayız, kontrol et
        if prefs.isServiceEnabled(service) {
            selectedService = service
            storedServiceRawValue = service.rawValue
            webViewManager.load(url: service.url)
        }
    }
}

// Görsel Efekt (Değişmedi, aynı kalıyor)
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
