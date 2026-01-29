import SwiftUI

struct PersistentWebView: View {
    let service: AIService
    
    var body: some View {
        // Hata buradaydı: AIWebView artık 'url' parametresi bekliyor.
        AIWebView(url: service.url)
            .id(service.id) // Servis değiştiğinde içeriğin yenilenmesi için
    }
}
