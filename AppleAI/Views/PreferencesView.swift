import SwiftUI

struct PreferencesView: View {
    @AppStorage("showGemini") private var showGemini = true
    @AppStorage("showChatGPT") private var showChatGPT = true
    @AppStorage("showYouTubeMusic") private var showYouTubeMusic = true
    
    var body: some View {
        TabView {
            // General Tab
            Form {
                Section(header: Text("Models")) {
                    Toggle("Gemini", isOn: $showGemini)
                    Toggle("ChatGPT", isOn: $showChatGPT)
                    Toggle("YouTube Music", isOn: $showYouTubeMusic)
                }
            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            // Diğer sekmeler (Varsa Pro vb. korunabilir, Custom API kaldırıldı)
        }
        .frame(width: 450, height: 250)
    }
}
