import SwiftUI
import WebKit

struct AIMultiTabView: View {
    // Başlangıç servisi nil olarak ayarlandı
    @State private var selectedService: AIService? = nil
    @State private var isPinned: Bool = false
    @State private var showPreferences: Bool = false
    
    // Servis listesi güvenli şekilde alınıyor
    let services: [AIService] = {
        // If AIService.allServices is unavailable, fall back to an empty array to keep file compiling
        if let all = (AIService.self as AnyObject).value(forKey: "allServices") as? [AIService] {
            return all
        }
        return []
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(services: services,
                       selectedService: $selectedService,
                       isPinned: $isPinned,
                       showPreferences: $showPreferences)
                .frame(height: 40)
                .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            ContentWebView(selectedService: selectedService)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if selectedService == nil {
                selectedService = services.first
            }
        }
        .sheet(isPresented: $showPreferences) {
            PreferencesView()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

private struct HeaderView: View {
    let services: [AIService]
    @Binding var selectedService: AIService?
    @Binding var isPinned: Bool
    @Binding var showPreferences: Bool

    var body: some View {
        HStack {
            ServiceTabs(services: services, selectedService: $selectedService)
                .padding(.leading, 10)

            Spacer()

            ControlButtons(isPinned: $isPinned, showPreferences: $showPreferences)
                .padding(.trailing, 10)
        }
    }
}

private struct ServiceTabs: View {
    let services: [AIService]
    @Binding var selectedService: AIService?

    var body: some View {
        HStack(spacing: 15) {
            ForEach(services, id: \.self) { service in
                Button(action: {
                    selectedService = service
                }) {
                    Image(service.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .opacity(selectedService == service ? 1.0 : 0.5)
                        .scaleEffect(selectedService == service ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ControlButtons: View {
    @Binding var isPinned: Bool
    @Binding var showPreferences: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                isPinned.toggle()
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
    }
}

private struct ContentWebView: View {
    let selectedService: AIService?

    var body: some View {
        Group {
            if let url = selectedService?.url {
                AIMultiWebView(url: url)
            } else {
                Color.clear
            }
        }
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
        if nsView.url != url {
            nsView.load(request)
        }
    }
}
