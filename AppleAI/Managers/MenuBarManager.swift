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
    @Published var isAlwaysOnTop: Bool = true
    
    override private init() {
        super.init()
        setupMenuBar()
        KeyboardShortcutManager.shared.setup()
        setupPopover()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
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
    
    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: CompactChatView(menuManager: self))
        self.popover = popover
    }
    
    @objc func menuBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
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
            // SOL TIK DÜZELTMESİ:
            if isPinned {
                // Pinliyse doğrudan pencereyi öne getiren fonksiyonu çağır
                // Bu fonksiyon artık "Zorla Öne Getir" yeteneğine sahip.
                createPinnedWindow()
            } else {
                togglePopover(sender)
            }
        }
    }
    
    func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }
        if popover == nil { setupPopover() }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Popover açılırken de uygulamayı öne çekelim
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func togglePin() {
        isPinned.toggle()
        if isPinned {
            popover?.close()
            popover = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.createPinnedWindow()
            }
        } else {
            pinnedWindow?.close()
            pinnedWindow = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupPopover()
                self.togglePopover(nil)
            }
        }
    }
    
    func toggleAlwaysOnTop() {
        guard let window = pinnedWindow else { return }
        isAlwaysOnTop.toggle()
        
        if isAlwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
    
    // YENİDEN DÜZENLENEN FONKSİYON: createPinnedWindow (Artık public erişimli gibi davranıyor)
    func createPinnedWindow() {
        // 1. EĞER PENCERE ZATEN VARSA:
        if let window = pinnedWindow {
            // "Always on Top" kapalı olsa bile, kullanıcı butona bastıysa
            // uygulamayı zorla öne getir ve odaklan.
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        // 2. YOKSA YENİ OLUŞTUR:
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.isFloatingPanel = true
        window.level = isAlwaysOnTop ? .floating : .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        window.title = "FloatBrowser"
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor.windowBackgroundColor
        window.minSize = NSSize(width: 300, height: 400)
        
        window.contentView = NSHostingView(rootView: CompactChatView(menuManager: self))
        window.center()
        
        self.pinnedWindow = window
        
        // İlk oluştuğunda da öne getir
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc func openSettings() {
        if let window = settingsWindow {
            NSApp.activate(ignoringOtherApps: true) // Ayarlar için de geçerli
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
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.settingsWindow = window
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
        }
    }
    
    @objc func quitApp() { NSApp.terminate(nil) }
    func togglePopupWindow() { togglePopover(nil) }
    func setup() {}
}
