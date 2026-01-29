import Foundation
import AppKit
import SwiftUI
import Combine

@MainActor
class KeyboardShortcutManager: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    static let shared = KeyboardShortcutManager()
    
    private init() {}
    
    // Pencereyi açıp kapatan fonksiyon
    func toggleWindow() {
        // MenuBarManager üzerindeki popover'ı tetikle
        MenuBarManager.shared.togglePopover(nil)
    }
    
    // Global kısayol dinleyicisi eklenebilir (Şimdilik basit tutuyoruz)
    func setupKeyboardShortcuts() {
        // İleride global hotkey eklemek istersen buraya kod gelecek.
        // Şimdilik boş bırakıyoruz ki çökme veya yetki hatası olmasın.
    }
}
