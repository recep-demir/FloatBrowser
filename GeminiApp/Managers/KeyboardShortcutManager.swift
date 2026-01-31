import Foundation
import AppKit
import SwiftUI

final class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private init() {}
    
    func setup() {
        // 1. GLOBAL MONITOR (Uygulama arka plandayken çalışır)
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            self.handleEvent(event)
        }
        
        // 2. LOCAL MONITOR (Uygulama aktifken/seçiliyken çalışır)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if self.handleEvent(event) {
                return nil // Tuş olayını yakaladık, sistem başkasına iletmesin
            }
            return event
        }
    }
    
    @discardableResult
    private func handleEvent(_ event: NSEvent) -> Bool {
        // Hedef: Option (Alt) + Command + G
        // KeyCode 5 = "G" harfi
        // Modifiers = .command ve .option
        
        if event.modifierFlags.contains(.command) &&
           event.modifierFlags.contains(.option) &&
           event.keyCode == 5 {
            
            DispatchQueue.main.async {
                let manager = MenuBarManager.shared
                if manager.isPinned {
                    // Eğer pinli ise pencereyi öne getir
                    manager.createPinnedWindow()
                } else {
                    // Değilse Popover'ı aç/kapat
                    manager.togglePopover(nil)
                }
            }
            return true
        }
        return false
    }
}

