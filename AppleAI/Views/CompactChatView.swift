import SwiftUI
import WebKit

struct CompactChatView: View {
    @State private var selectedService: AIService
    @State private var isLoading = true
    @StateObject private var preferences = PreferencesManager.shared
    let services: [AIService]
    let closeAction: () -> Void
    
    // Varsayılan init: aiServices yerine AIService.allCases kullanıyoruz
    init(services: [AIService] = AIService.allCases, closeAction: @escaping () -> Void) {
        self.services = services
        self.closeAction = closeAction
        // Güvenli başlatma: Gemini ile başla
        _selectedService = State(initialValue: services.contains(.gemini) ? .gemini : (services.first ?? .gemini))
    }
    
    // Belirli bir servis ile başlatma
    init(initialService: AIService, services: [AIService] = AIService.allCases, closeAction: @escaping () -> Void) {
        self.services = services
        self.closeAction = closeAction
        _selectedService = State(initialValue: initialService)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Servis Seçici İkonlar
            HStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(services) { service in
                            ServiceIconButton(
                                service: service,
                                isSelected: service == selectedService,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedService = service
                                    }
                                    ensureWebViewFocus(delay: 0.5)
                                }
                            )
                            .id(service.id)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 40)
                
                Spacer()
            }
            .padding(.vertical, 6)
            .background(Color(NSColor.windowBackgroundColor))
            
            // Seçili servis alt çizgisi (Renkleri elle atıyoruz)
            Rectangle()
                .frame(height: 2)
                .foregroundColor(getServiceColor(selectedService))
            
            // WebView
            PersistentWebView(service: selectedService, isLoading: $isLoading)
                .background(KeyboardFocusModifier(onAppear: {
                    ensureWebViewFocus(delay: 0.5)
                }))
        }
        .frame(width: 400, height: 600)
        .onAppear {
            setupPeriodicFocusCheck()
            ensureWebViewFocus(delay: 0.2)
        }
    }
    
    // Servis renkleri için yardımcı fonksiyon (Enum'da olmadığı için)
    private func getServiceColor(_ service: AIService) -> Color {
        switch service {
        case .chatgpt: return Color.green
        case .gemini: return Color.blue
        case .youtubeMusic: return Color.red
        }
    }

    // --- Mevcut Fokus Fonksiyonları (Dokunma) ---
    private func setupPeriodicFocusCheck() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let window = NSApplication.shared.keyWindow, window.isVisible else { return }
            if window.isKeyWindow {
                if let firstResponder = window.firstResponder {
                    let className = NSStringFromClass(type(of: firstResponder))
                    if !className.contains("WKWebView") && !className.contains("KeyboardResponderView") {
                        ensureWebViewFocus(delay: 0.0)
                    }
                } else {
                    ensureWebViewFocus(delay: 0.0)
                }
            }
        }
    }
    
    private func ensureWebViewFocus(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            focusWebView()
        }
    }
    
    private func focusWebView() {
        guard let window = NSApplication.shared.keyWindow else { return }
        func findAndFocus(in view: NSView) -> Bool {
            if NSStringFromClass(type(of: view)).contains("KeyboardResponderView") || NSStringFromClass(type(of: view)).contains("WKWebView") {
                window.makeFirstResponder(view)
                return true
            }
            for subview in view.subviews { if findAndFocus(in: subview) { return true } }
            return false
        }
        if let contentView = window.contentView { _ = findAndFocus(in: contentView) }
    }
}

// Sadeleştirilmiş İkon Butonu
struct ServiceIconButton: View {
    let service: AIService
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                if service == .youtubeMusic {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(isSelected ? .red : .gray)
                } else {
                    Image(service.iconName) // icon -> iconName
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .opacity(isSelected ? 1.0 : 0.5)
                }
                
                Text(service.name)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .primary : .gray)
            }
            .frame(width: 58, height: 38)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct KeyboardFocusModifier: NSViewRepresentable {
    let onAppear: () -> Void
    func makeNSView(context: Context) -> NSView { NSView() }
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { onAppear() }
    }
}

struct CompactChatView_Previews: PreviewProvider {
    static var previews: some View {
        CompactChatView(closeAction: {})
    }
}
