import SwiftUI

@main
struct AIToolsApp: App {
    // macOS uygulamalarında yaşam döngüsünü yönetmek için AppDelegate kullanıyoruz
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Ayarlar penceresi (Command + , ile açılır)
        Settings {
            PreferencesView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Uygulama başladığında MenuBar ikonunu ve özelliklerini yükle
        MenuBarManager.shared.setup()
        
        // Dock ikonunu gizle (Sadece menü çubuğunda çalışması için)
        // Eğer hem dock hem menüde görünsün istersen bu satırı sil.
        // NSApp.setActivationPolicy(.accessory)
    }
}
