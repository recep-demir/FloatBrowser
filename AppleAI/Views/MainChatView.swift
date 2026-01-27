import SwiftUI
import WebKit

struct MainChatView: View {
    // Varsayılan servis olarak Gemini seçili başlar
    @State private var selectedService: AIService
    
    // Eski kodların kırılmaması için init parametrelerini esnek tutuyoruz
    init(initialService: AIService? = nil, services: [AIService] = AIService.allCases) {
        if let service = initialService {
            _selectedService = State(initialValue: service)
        } else {
            // Eğer bir servis belirtilmemişse varsayılanı kullan
            _selectedService = State(initialValue: .gemini)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Üst Menü (Header) ---
            HStack(spacing: 12) {
                // Servis Seçici
                ServicePickerView(selectedService: $selectedService)
                    .frame(width: 160)
                
                Spacer()
                
                // Sağ tarafa ek butonlar (Ayarlar vb.) eklenebilir
                // Şimdilik temiz bırakıyoruz
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)
            
            // --- Web Tarayıcı ---
            // AIWebView artık hem URL hem Service bekliyor
            AIWebView(url: selectedService.url, service: selectedService)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Önizleme için
struct MainChatView_Previews: PreviewProvider {
    static var previews: some View {
        MainChatView()
    }
}
