import AppKit
import SwiftUI
import Combine

class MenuBarManager: NSObject, ObservableObject, NSWindowDelegate {
    static let shared = MenuBarManager()
    
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var pinnedWindow: NSPanel?
    
    @Published var isPinned: Bool = false
    @Published var isAlwaysOnTop: Bool = true
    
    override private init() {
        super.init()
        setupMenuBar()
        setupPopover()
        
        // Kısayol yöneticisini başlat
        KeyboardShortcutManager.shared.setup()
    }
    
    // --- KISAYOL TETİKLEYİCİSİ ---
    // --- KISAYOL TETİKLEYİCİSİ (GÜNCELLENDİ) ---
        func toggleAppFromShortcut() {
            // Uygulamanın şu anki aktiflik durumunu al
            // Eğer başka bir uygulama kullanıyorsan (örn: Chrome), bu değer false olur.
            let wasActive = NSApp.isActive
            
            // Uygulamayı her durumda öne çek (Focus alması için)
            NSApp.activate(ignoringOtherApps: true)
            
            // 1. PINLI PENCERE KONTROLÜ
            if let window = pinnedWindow, window.isVisible {
                // Eğer uygulama ZATEN en öndeyse ve kullanıcı kısayola bastıysa -> GİZLE/KAPAT
                // (Kullanıcı odaklıyken kısayola basarsa kapatmak istiyordur)
                if wasActive && window.isKeyWindow {
                    window.close()
                } else {
                    // Eğer uygulama ARKADAYSA (başka pencere aktifse) -> SADECE ÖNE GETİR
                    // Kapatmadığımız için Pin modu bozulmaz, pencere en öne gelir.
                    window.makeKeyAndOrderFront(nil)
                }
                return
            }
            
            // 2. POPOVER (FLOAT) KONTROLÜ
            if let popover = popover, popover.isShown {
                // Float pencere zaten odak kaybında kapanır ama yine de manuel kapatma desteği
                popover.performClose(nil)
                return
            }
            
            // 3. HİÇBİRİ AÇIK DEĞİLSE -> AÇ
            // En son durumu hatırla (Pinli ise pinli aç)
            if isPinned {
                createPinnedWindow()
            } else {
                if let button = statusItem?.button {
                    togglePopover(button)
                }
            }
        }
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if let customIcon = NSImage(named: "MenuBarIcon") {
                let resizedIcon = resizeImage(image: customIcon, w: 18, h: 18)
                resizedIcon.isTemplate = false
                button.image = resizedIcon
            } else if let appIcon = NSImage(named: "AppIcon") {
                let resizedIcon = resizeImage(image: appIcon, w: 18, h: 18)
                resizedIcon.isTemplate = false
                button.image = resizedIcon
            } else {
                let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
                button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Gemini")?.withSymbolConfiguration(config)
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
            
            let zoomItem = NSMenuItem()
            let zoomView = NSHostingView(rootView: ZoomControlMenu())
            zoomView.frame = NSRect(x: 0, y: 0, width: 220, height: 40)
            zoomItem.view = zoomView
            menu.addItem(zoomItem)
            
            menu.addItem(NSMenuItem.separator())
            let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
            launchItem.target = self
            launchItem.state = PreferencesManager.shared.launchAtLogin ? .on : .off
            menu.addItem(launchItem)
            
            menu.addItem(NSMenuItem.separator())
            let infoItem = NSMenuItem(title: "Global Shortcut: ⌥⌘G", action: nil, keyEquivalent: "")
            infoItem.isEnabled = false
            menu.addItem(infoItem)
            
            menu.addItem(NSMenuItem.separator())
            let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
            quitItem.target = self
            menu.addItem(quitItem)
            
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        } else {
            // SOL TIK
            // Uygulamayı öne getir (Focus sorunu çözümü)
            NSApp.activate(ignoringOtherApps: true)
            
            if isPinned {
                if let window = pinnedWindow {
                    if window.isVisible { window.orderFront(nil) } else { window.makeKeyAndOrderFront(nil) }
                } else { createPinnedWindow() }
            } else { togglePopover(sender) }
        }
    }
    
    @objc func toggleLaunchAtLogin() { PreferencesManager.shared.launchAtLogin.toggle() }
    @objc func quitApp() { NSApp.terminate(nil) }
    
    func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }
        if popover == nil { setupPopover() }
        if let popover = popover {
            if popover.isShown { popover.performClose(sender) } else {
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func togglePin() {
        if isPinned {
            // UNPIN: Pinli moddan çık, Pencereyi kapat, Popover'ı aç
            isPinned = false
            pinnedWindow?.close()
            pinnedWindow = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupPopover()
                self.togglePopover(nil)
            }
        } else {
            // PIN: Pinli moda geç, Popover'ı kapat, Pencereyi aç
            isPinned = true
            popover?.close()
            popover = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.createPinnedWindow()
            }
        }
    }
    
    func toggleAlwaysOnTop() {
        guard let window = pinnedWindow else { return }
        isAlwaysOnTop.toggle()
        window.level = isAlwaysOnTop ? .floating : .normal
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == pinnedWindow {
            DispatchQueue.main.async {
                self.isPinned = false
                self.pinnedWindow = nil
            }
        }
    }
    
    func createPinnedWindow() {
        if let window = pinnedWindow {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.isFloatingPanel = true
        window.level = isAlwaysOnTop ? .floating : .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.delegate = self
        window.backgroundColor = NSColor.windowBackgroundColor
        window.contentView = NSHostingView(rootView: CompactChatView(menuManager: self))
        window.center()
        self.pinnedWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

// ZOOM MENÜSÜ
struct ZoomControlMenu: View {
    @ObservedObject var prefs = PreferencesManager.shared
    var body: some View {
        HStack {
            Text("Text Size").font(.system(size: 13, weight: .regular))
            Spacer()
            Button(action: { prefs.decreaseZoom() }) {
                Image(systemName: "chevron.left").font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20).background(Color.gray.opacity(0.1)).cornerRadius(4)
            }.buttonStyle(PlainButtonStyle())
            Text("%\(Int(prefs.zoomLevel * 100))").font(.system(size: 13, weight: .medium).monospacedDigit()).frame(width: 45, alignment: .center)
            Button(action: { prefs.increaseZoom() }) {
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20).background(Color.gray.opacity(0.1)).cornerRadius(4)
            }.buttonStyle(PlainButtonStyle())
        }.padding(.horizontal, 16).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
