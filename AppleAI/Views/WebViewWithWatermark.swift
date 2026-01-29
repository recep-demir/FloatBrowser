import SwiftUI

struct WebViewWithWatermark: View {
    let service: AIService
    
    var body: some View {
        // Watermark olmadan doğrudan WebView'i göster
        // Service'den URL'i alıp AIWebView'e veriyoruz
        AIWebView(url: service.url)
    }
}
