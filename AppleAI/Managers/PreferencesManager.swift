import Foundation
import SwiftUI
import ServiceManagement
import Combine

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    // Servislerin Görünürlüğü
    @AppStorage("showGemini") var showGemini: Bool = true
    @AppStorage("showChatGPT") var showChatGPT: Bool = true
    @AppStorage("showYouTubeMusic") var showYouTubeMusic: Bool = true
    
    // Başlangıçta Çalıştır
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            toggleLaunchAtLogin(launchAtLogin)
        }
    }
    
    // Global Kısayol (Örn: Option + Command + G)
    // Bu sadece UI için basit bir tutucu, gerçek dinleme KeyboardShortcutManager'da
    @AppStorage("shortcutEnabled") var shortcutEnabled: Bool = true
    
    private init() {}
    
    func isServiceEnabled(_ service: AIService) -> Bool {
        switch service {
        case .gemini: return showGemini
        case .chatgpt: return showChatGPT
        case .youtubeMusic: return showYouTubeMusic
        }
    }
    
    private func toggleLaunchAtLogin(_ enabled: Bool) {
        // macOS 13+ Modern Yöntem
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Launch at login hatası: \(error)")
            }
        }
    }
}
