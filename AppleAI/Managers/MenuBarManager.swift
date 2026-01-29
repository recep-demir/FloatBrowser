import AppKit
import SwiftUI
import Combine

class MenuBarManager: NSObject, ObservableObject, NSWindowDelegate {
    static let shared = MenuBarManager()
    
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var pinnedWindow: NSPanel?
    var settingsWindow: NSWindow?
    
    @Published var isPinned: Bool = false
    
    override private init() {
        super.init()
        setupMenuBar()
        // Kısayolları başlat
        KeyboardShortcutManager.shared.setup()
        // İlk açılış için popover'ı hazırla
        setupPopover()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // İKON AYARLARI
            if let appIcon = NSImage(named: "MenuBarIcon") {
                let resizedIcon = resizeImage(image: appIcon, w: 20, h: 20)
                resizedIcon.isTemplate = true
                button.image = resizedIcon
            } else {
                let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
                button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "FloatBrowser")?.withSymbolConfiguration(config)
                button.image?.isTemplate = true
            }
            
            button.action = #selector(menuBarButtonClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    // Yardımcı: Görsel Boyutlandırma
    private func resizeImage(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                   from: NSMakeRect(0, 0, image.size.width, image.size.height),
                   operation: .sourceOver,
                   fraction: 1.0)
        newImage.unlockFocus()
        newImage.isTemplate = true
        return newImage
    }
    
    // POPOVER'I SIFIRDAN YARATAN FONKSİYON
    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        // Her seferinde Taptaze bir View oluşturuyoruz
        popover.contentViewController = NSHostingController(rootView: CompactChatView(menuManager: self))
        self.popover = popover
    }
    
    @objc func menuBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            // SAĞ TIK MENÜSÜ
            let menu = NSMenu()
            let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
            settingsItem.target = self
            menu.addItem(settingsItem)
            
            menu.addItem(NSMenuItem.separator())
            
            let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
            quitItem.target = self
            menu.addItem(quitItem)
            
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        } else {
            // SOL TIK
            if isPinned {
                if let window = pinnedWindow {
                    if window.isVisible {
                        window.orderFront(nil)
                    } else {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            } else {
                togglePopover(sender)
            }
        }
    }
    
    func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }
        
        // Eğer popover yoksa (unpin sonrası), yeniden yarat
        if popover == nil {
            setupPopover()
        }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    // --- KRİTİK YAŞAM DÖNGÜSÜ DÜZELTMESİ ---
    func togglePin() {
        isPinned.toggle()
        
        if isPinned {
            // 1. PIN MODUNA GEÇİŞ (Pencere Aç)
            
            // Popover'ı kapat ve TAMAMEN YOK ET (Memory'den silinsin)
            popover?.close()
            popover = nil
            
            // Kısa bir gecikmeyle Pencereyi aç (Çakışmayı önler)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.createPinnedWindow()
            }
        } else {
            // 2. UNPIN MODUNA GEÇİŞ (Pencereyi Kapat, Popover'a Dön)
            
            // Pencereyi kapat ve YOK ET
            pinnedWindow?.close()
            pinnedWindow = nil
            
            // Popover'ı SIFIRDAN YARAT ve aç
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupPopover() // Yeni, taptaze popover
                self.togglePopover(nil)
            }
        }
    }
    
    func createPinnedWindow() {
        if let _ = pinnedWindow {
            pinnedWindow?.makeKeyAndOrderFront(nil)
            return
        }
        
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.isFloatingPanel = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor.clear
        window.minSize = NSSize(width: 300, height: 400)
        
        window.contentView = NSHostingView(rootView: CompactChatView(menuManager: self))
        window.center()
        
        self.pinnedWindow = window
        window.makeKeyAndOrderFront(nil)
    }
    
    // --- AYARLAR PENCERESİ (Çökme Çözümü) ---
    @objc func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 350),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.center()
        window.level = .floating + 1
        window.contentView = NSHostingView(rootView: PreferencesView())
        
        // Pencere kapandığında hemen bellekten silinmesini engelle
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
    }
    
    // Pencere kapandığında değişkeni güvenli şekilde temizle
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
        }
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    func togglePopupWindow() { togglePopover(nil) }
    func setup() {}
}
