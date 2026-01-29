import SwiftUI
import AppKit

@main
struct AIToolsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        _ = ProManager.shared
        menuBarManager = MenuBarManager.shared
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // 1. Dock'ta görünmesini engelle
        NSApp.setActivationPolicy(.accessory)
        
        // 2. Pencereyi veya Popover'ı Aç
        let manager = MenuBarManager.shared
        if manager.isPinned {
            manager.pinnedWindow?.makeKeyAndOrderFront(nil)
        } else {
            manager.togglePopover(nil)
        }
        
        // 3. YENİ ÖZELLİK: "Müziğe Geç" Sinyali Gönder!
        // Bu sinyali arayüz (CompactChatView) yakalayacak.
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToYouTubeMusic"), object: nil)
        
        return true
    }
}
