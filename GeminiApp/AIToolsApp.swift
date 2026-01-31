import SwiftUI
import AppKit

@main
struct AIToolsApp: App {
    // AppDelegate'i SwiftUI yaşam döngüsüne bağlıyoruz
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
        // 1. Uygulamayı "Aksesuar" modunda başlat (Dock'ta görünmez)
        NSApp.setActivationPolicy(.accessory)
        
        // HATALI SATIR SİLİNDİ (_ = ProManager.shared)
        
        // 2. Menü Çubuğu Yöneticisini Başlat
        menuBarManager = MenuBarManager.shared
    }
    
    // Uygulama ikonuna tıklandığında (Dock veya Finder) pencereyi aç
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        
        let manager = MenuBarManager.shared
        if manager.isPinned {
            // Pinliyse pencereyi öne getir
            manager.pinnedWindow?.makeKeyAndOrderFront(nil)
        } else {
            // Değilse Popover'ı aç
            manager.togglePopover(nil)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Kapanış işlemleri
    }
}
