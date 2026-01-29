import Foundation
import SwiftUI

enum AIService: String, CaseIterable, Identifiable {
    case gemini
    case chatgpt
    case youtubeMusic
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .gemini: return "Gemini"
        case .chatgpt: return "ChatGPT"
        case .youtubeMusic: return "YouTube Music"
        }
    }
    
    var url: URL {
        switch self {
        case .gemini: return URL(string: "https://gemini.google.com/app")!
        case .chatgpt: return URL(string: "https://chatgpt.com")!
        case .youtubeMusic: return URL(string: "https://music.youtube.com")!
        }
    }
    
    // İkon sistemi: Varsa asset, yoksa SF Symbol
    var iconName: String {
        switch self {
        case .gemini: return "sparkles" // Veya asset varsa asset ismi
        case .chatgpt: return "message.fill" // Veya 'chatgpt' asset ismi
        case .youtubeMusic: return "play.circle.fill"
        }
    }
    
    // Assets klasöründe resim olup olmadığını kontrol etmek yerine
    // doğrudan sistem ikonlarını kullanmak daha modern ve 'Float' temasına uygun olabilir.
    // Ancak Asset kullanmak istersen burayı ona göre güncelleyebiliriz.
    var isSystemIcon: Bool {
        return true // Şimdilik modern görünüm için hepsini SF Symbol yapalım, çökme riskini azaltır.
    }
}
