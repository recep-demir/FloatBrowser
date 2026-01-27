import Foundation
import SwiftUI
import Combine

class ProManager: ObservableObject {
    static let shared = ProManager()
    
    // Pro özellikleri her zaman açık
    @Published var isProUser: Bool = true
    
    // Diğer değişkenler hata vermemesi için formalite olarak tutuluyor
    @Published var showUpgradeSheet: Bool = false
    @Published var trialDaysRemaining: Int = 99
    
    // Controls whether the app should show a Pro upgrade prompt
    @Published var shouldShowUpgradePrompt: Bool = true

    // Call when the prompt has been shown so we don't show it repeatedly
    func markUpgradePromptShown() {
        shouldShowUpgradePrompt = false
    }
    
    private init() {}
    
    func checkProStatus() {
        // Kontrol yapmaya gerek yok, her zaman pro
        self.isProUser = true
    }
    
    func unlockPro() {
        self.isProUser = true
    }
}

