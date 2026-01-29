import SwiftUI
import WebKit

struct CompactChatView: View {
    @State private var selectedService: AIService = .gemini
    @StateObject private var webViewManager = WebViewManager.shared
    @ObservedObject var menuManager: MenuBarManager
    @ObservedObject var prefs = PreferencesManager.shared
    
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
                
                // 2. AYARLAR SORUNU: Kapatılan servisleri gizle
                HStack(spacing: 20) {
                    ForEach(AIService.allCases.filter { prefs.isServiceEnabled($0) }) { service in
                        Button(action: {
                            selectedService = service
                            storedServiceRawValue = service.rawValue
                            webViewManager.load(url: service.url)
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
            ZStack {
                Color.black
                AIWebView(url: selectedService.url)
                    .id(selectedService.id)
                    // .id() kullanımı bazen gereksiz yenileme yapar,
                    // ama AIWebView içindeki kontrolümüz bunu engelleyecek.
            }
        }
        // 3. RESIZE SORUNU: Sabit .frame(width: 400...) KALDIRILDI.
        // Onun yerine minWidth/minHeight kullanıyoruz ki kullanıcı büyütebilsin.
        .frame(minWidth: 350, minHeight: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if let savedService = AIService(rawValue: storedServiceRawValue), prefs.isServiceEnabled(savedService) {
                selectedService = savedService
            } else {
                // Eğer kayıtlı servis ayarlardan kapatıldıysa ilk açık olana geç
                if let firstAvailable = AIService.allCases.first(where: { prefs.isServiceEnabled($0) }) {
                    selectedService = firstAvailable
                }
            }
            webViewManager.load(url: selectedService.url)
        }
    }
}


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
