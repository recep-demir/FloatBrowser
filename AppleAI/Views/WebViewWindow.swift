import SwiftUI
import WebKit

struct WebViewWindow: View {
    let service: AIService
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern bir üst bar (Opsiyonel: Sadece ikon istiyorsan burayı daraltabilirsin)
            HStack {
                Text(service.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Yeni Cache sistemini kullanan WebView
            RepresentableWebView(webView: WebViewCache.shared.getWebView(forId: service.id, url: service.url))
        }
    }
}

// WKWebView'i SwiftUI içinde göstermek için yardımcı yapı
struct RepresentableWebView: NSViewRepresentable {
    let webView: WKWebView
    
    func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}

