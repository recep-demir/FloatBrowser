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

// App delegate to handle application lifecycle
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar uygulaması olarak ayarla
        NSApp.setActivationPolicy(.accessory)
        
        // ProManager'ı başlat (Herkes Pro)
        _ = ProManager.shared
        
        // MenuBar yöneticisini başlat
        menuBarManager = MenuBarManager.shared
        
        // Uygulama kapanmasını önle (Persistent Window gerekirse burada tutulur)
        // FloatBrowser mantığında pencereyi MenuBarManager yönetiyor.
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Kapanış işlemleri
    }
}
