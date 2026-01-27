import SwiftUI

struct WebViewWindow: View {
    let service: AIService
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık Barı
            HStack {
                HStack(spacing: 8) {
                    // Düzeltme 1: 'icon' yerine 'iconName' kullanıldı
                    Image(systemName: service.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.primary) // Düzeltme 2: 'color' yerine sistem rengi
                    
                    Text(service.name)
                        .font(.headline)
                }
                
                Spacer()
                
                // Yükleniyor göstergesi
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                }
                
                // Yenileme Butonu
                Button(action: {
                    if let webView = WebViewCache.shared.webViews[service.id] {
                        webView.reload()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor)) // Arkaplan rengi
            
            Divider()
            
            // WebView Alanı
            // Eğer PersistentWebView hata verirse burayı AIWebView(service: service) yapabilirsiniz.
            PersistentWebView(service: service, isLoading: $isLoading)
        }
    }
}
