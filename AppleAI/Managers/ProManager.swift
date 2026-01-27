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
    
    private init() {}
    
    func checkProStatus() {
        // Kontrol yapmaya gerek yok, her zaman pro
        self.isProUser = true
    }
    
    func unlockPro() {
        self.isProUser = true
    }
}
