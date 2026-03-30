import Cocoa
import Carbon

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    private var hotKeyRef: EventHotKeyRef?
    private init() {}
    
    func setup() {
        let hotKeyID = EventHotKeyID(signature: OSType(1196131404), id: 1)
        
        // 1. DEĞİŞEN KISIM: Sadece Option tuşu (cmdKey kaldırıldı)
        let modifiers = UInt32(optionKey)
        // 2. DEĞİŞEN KISIM: Space (Boşluk) tuşunun scancode'u 49'dur
        let keyCode = UInt32(49)
        
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
        
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                DispatchQueue.main.async {
                    print("🎹 Global Kısayol Tetiklendi (Option + Space)")
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
            print("✅ Carbon Global Kısayol Aktif: Option + Space")
        } else {
            print("❌ Event Handler kurulum hatası: \(status)")
        }
    }
}
