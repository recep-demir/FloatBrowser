import SwiftUI

struct ServicePickerView: View {
    @Binding var selectedService: AIService
    
    var body: some View {
        // Doğrudan AIService objesi üzerinden seçim yapabiliriz (Hashable olduğu için)
        Picker("Service", selection: $selectedService) {
            ForEach(aiServices) { service in
                HStack {
                    // Hata veren 'icon' yerine 'iconName' kullanıyoruz
                    Image(systemName: service.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.primary) // Modelde renk olmadığı için standart renk
                    
                    Text(service.name)
                }
                .tag(service) // Servis objesinin kendisi tag olur
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
        .labelsHidden()
    }
}
