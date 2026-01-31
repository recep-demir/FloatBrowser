import Cocoa
import Carbon

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {}
    
    func setup() {
        // 1. HotKey Tanımları (Command + Option + G)
        // 'GLBL' imzasının sayısal değeri: 1196131404
        let hotKeyID = EventHotKeyID(signature: OSType(1196131404), id: 1)
        
        // Modifiers: Command (cmdKey) + Option (optionKey)
        // Carbon'da bu sabitler UInt32 bekler
        let modifiers = UInt32(cmdKey | optionKey)
        let keyCode = UInt32(5) // 'G' tuşu scancode
        
        // 2. Kısayolu Sisteme Kaydet
        var status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("❌ Carbon HotKey kaydı başarısız: \(status)")
            return
        }
        
        // 3. Olay İşleyicisini (Event Handler) Kur
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        // InstallEventHandler çağrısı
        status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                // Tuşa basıldığında çalışacak blok
                DispatchQueue.main.async {
                    print("🎹 Global Kısayol Tetiklendi (Opt+Cmd+G)")
                    // HATA BURADAYDI: togglePopover() yerine parametresiz
                    // olan toggleAppFromShortcut() kullanıyoruz.
                    MenuBarManager.shared.toggleAppFromShortcut()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
        
        if status == noErr {
            print("✅ Carbon Global Kısayol Aktif: Option+Command+G")
        } else {
            print("❌ Event Handler kurulum hatası: \(status)")
        }
    }
}
