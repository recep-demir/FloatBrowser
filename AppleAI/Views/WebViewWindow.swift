import SwiftUI
import WebKit

struct WebViewWindow: View {
    let service: AIService
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: service.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.primary)
                    
                    Text(service.name)
                        .font(.headline)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                }
                
                // Yenileme Butonu (DÜZELTİLEN KISIM)
                Button(action: {
                    // Artık hata vermeyecek güvenli yöntem:
                    let webView = WebViewCache.shared.getWebView(for: service)
                    webView.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // WebView
            let initialURL = URL(string: "about:blank")!
            AIWebView(url: initialURL, service: service)
        }
    }
}

