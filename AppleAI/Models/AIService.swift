import Foundation
import SwiftUI

enum AIService: String, CaseIterable, Identifiable {
    case chatgpt
    case gemini
    case youtubeMusic
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .chatgpt: return "ChatGPT"
        case .gemini: return "Gemini"
        case .youtubeMusic: return "YouTube Music"
        }
    }
    
    var url: URL {
        switch self {
        case .chatgpt: return URL(string: "https://chatgpt.com")!
        case .gemini: return URL(string: "https://gemini.google.com")!
        case .youtubeMusic: return URL(string: "https://music.youtube.com")!
        }
    }
    
    var iconName: String {
        // Assets.xcassets içinde bu isimlerde (chatgpt, gemini) resimler olmalı.
        // YouTube Music için sistem ikonu kullanacağız, kod tarafında ayarladık.
        switch self {
        case .chatgpt: return "chatgpt"
        case .gemini: return "gemini" // Eğer asset ismi 'google' ise burayı 'google' yap
        case .youtubeMusic: return "music.note"
        }
    }
}
