import Cocoa
import Carbon

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    // G tuşunun kodu 5'tir.
    private let kKeyG: UInt16 = 5
    
    func setup() {
        // Varsa eskileri temizle
        if let gMonitor = globalMonitor { NSEvent.removeMonitor(gMonitor) }
        if let lMonitor = localMonitor { NSEvent.removeMonitor(lMonitor) }
        
        // 1. GLOBAL MONİTÖR (Uygulama arka plandayken çalışır)
        // macOS'te "Gizlilik ve Güvenlik > Erişilebilirlik" izni şarttır.
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event, isLocal: false)
        }
        
        // 2. LOCAL MONİTÖR (Uygulama aktifken çalışır)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let self = self, self.handleEvent(event, isLocal: true) {
                return nil // Tuşu sisteme iletme (G harfi yazmasın)
            }
            return event
        }
    }
    
    // Tuş yakalama mantığı
    @discardableResult private func handleEvent(_ event: NSEvent, isLocal: Bool) -> Bool {
        // Sadece 'G' tuşuna basıldıysa ilgilen
        guard event.keyCode == kKeyG else { return false }
        
        // Modifier tuşlarını kontrol et (Command + Option)
        // .contains kullanarak CapsLock vs. açık olsa bile çalışmasını sağlıyoruz.
        let flags = event.modifierFlags
        if flags.contains(.command) && flags.contains(.option) {
            
            // Ana thread'de işlemi yap
            DispatchQueue.main.async {
                MenuBarManager.shared.toggleAppFromShortcut()
            }
            return true
        }
        return false
    }
}

