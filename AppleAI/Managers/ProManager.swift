import Foundation
import Combine

class ProManager: ObservableObject {
    static let shared = ProManager()
    
    // Herkes Pro
    @Published var isProUser: Bool = true
    
    // --- Uyumluluk Değişkenleri (Hata Vermemesi İçin) ---
    
    // ProSplashView hatasını önlemek için
    @Published var trialDaysRemaining: Int = 365
    @Published var isTrialMode: Bool = false
    
    // ProUpgradePrompt hatasını önlemek için
    // Bu değer 'false' olduğu sürece yükseltme ekranı çıkmaz
    @Published var shouldShowUpgradePrompt: Bool = false
    
    private init() {}
    
    func checkProStatus() {
        self.isProUser = true
    }
    
    func restorePurchase() {
        self.isProUser = true
    }
    
    // ProUpgradePrompt içinden çağrılan fonksiyon (Boş bırakıyoruz)
    func markUpgradePromptShown() {
        // Zaten göstermediğimiz için bir şey yapmaya gerek yok
    }
}
