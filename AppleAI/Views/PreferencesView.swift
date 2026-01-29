import SwiftUI

struct PreferencesView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ModelsSettingsView()
                .tabItem {
                    Label("Models", systemImage: "cpu")
                }
        }
        .frame(width: 500, height: 300)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    
    var body: some View {
        Form {
            Section {
                // 7. LAUNCH AT LOGIN
                Toggle("Launch at Login", isOn: $prefs.launchAtLogin)
                    .toggleStyle(SwitchToggleStyle())
                
                Text("Start FloatBrowser automatically when you log in.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider().padding(.vertical)
            
            Section {
                // 8. KISAYOL BİLGİSİ
                HStack {
                    Text("Global Shortcut:")
                    Spacer()
                    Text("⌥ ⌘ G") // Option + Command + G
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                Text("Press Option + Command + G to toggle FloatBrowser from anywhere.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct ModelsSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Enabled Services")) {
                Toggle("Gemini", isOn: $prefs.showGemini)
                Toggle("ChatGPT", isOn: $prefs.showChatGPT)
                Toggle("YouTube Music", isOn: $prefs.showYouTubeMusic)
            }
        }
        .padding()
    }
}
