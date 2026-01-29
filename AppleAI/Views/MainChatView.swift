import SwiftUI

struct MainChatView: View {
    // Varsayılan olarak Gemini
    @State private var selectedService: AIService = .gemini
    
    var body: some View {
        VStack(spacing: 0) {
            // Basit Header
            HStack {
                Text("FloatBrowser")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Picker("Service", selection: $selectedService) {
                    ForEach(AIService.allCases) { service in
                        Text(service.name).tag(service)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 300)
                .padding(.trailing)
            }
            .frame(height: 40)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Düzeltilen Kısım: AIWebView artık 'service' değil 'url' alıyor
            AIWebView(url: selectedService.url)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}
