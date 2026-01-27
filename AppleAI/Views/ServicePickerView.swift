import SwiftUI

struct ServicePickerView: View {
    @Binding var selectedService: AIService
    // Varsayılan olarak tüm servisleri al, dışarıdan verilmezse sorun çıkmaz
    var services: [AIService] = AIService.allCases
    @ObservedObject var proManager = ProManager.shared
    
    var body: some View {
        Picker("", selection: $selectedService) {
            ForEach(services) { service in
                HStack {
                    // İkon Mantığı: YouTube Music için sistem ikonu, diğerleri için Asset
                    if service == .youtubeMusic {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.red)
                    } else {
                        Image(service.iconName) // .icon yerine .iconName
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        // .foregroundColor(service.color) kaldırıldı çünkü artık renk tanımlı değil
                    }
                    
                    Text(service.name)
                    
                    // isProOnly kontrolü kaldırıldı (Herkes Pro olduğu için)
                }
                .tag(service) // AIService enum olduğu için tag çalışır
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
    }
}

// Preview Hatasını Çözmek İçin:
struct ServicePickerView_Previews: PreviewProvider {
    static var previews: some View {
        // aiServices yerine direkt AIService.allCases veya varsayılan değer kullanılır
        ServicePickerView(selectedService: .constant(.gemini))
    }
}
