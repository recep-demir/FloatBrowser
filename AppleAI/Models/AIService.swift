import Foundation

struct AIService: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var url: URL
    var iconName: String // SF Symbol ismi veya Asset ismi
    var isEnabled: Bool = true
    
    // Equatable ve Hashable uyumluluğu
    static func == (lhs: AIService, rhs: AIService) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Global servis listesi
let aiServices: [AIService] = [
    AIService(id: "gemini", name: "Gemini", url: URL(string: "https://gemini.google.com")!, iconName: "sparkles"),
    AIService(id: "chatgpt", name: "ChatGPT", url: URL(string: "https://chat.openai.com")!, iconName: "message"),
    AIService(id: "youtubemusic", name: "YouTube Music", url: URL(string: "https://music.youtube.com")!, iconName: "play.circle")
]
