import AppKit
import SwiftUI
import WebKit
import ServiceManagement
import Combine

class MenuBarManager: NSObject, NSMenuDelegate, NSWindowDelegate {
    static let shared = MenuBarManager() // Singleton erişimi için
    
    private var statusItem: NSStatusItem!
    private var popupWindow: NSWindow?
    private var shortcutManager: KeyboardShortcutManager!
    private var eventMonitor: Any?
    private var statusMenu: NSMenu!
    private var preferencesWindow: NSWindow?
    private var localEventMonitor: Any?
    
    // Açık olan servisi tutmak için (Notification ile gelirse)
    private var pendingService: AIService?
    
    override init() {
        super.init()
    }
    
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Assets içindeki "MenuBarIcon" resmini kullan
            if let iconImage = NSImage(named: "MenuBarIcon") {
                iconImage.isTemplate = true // Karanlık/Aydınlık mod uyumu
                button.image = iconImage
                button.image?.size = NSSize(width: 18, height: 18)
            } else {
                // Yedek olarak sistem ikonu
                button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "FloatBrowser")
            }
            button.imagePosition = .imageLeft
            
            button.target = self
            button.action = #selector(handleStatusItemClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusMenu = createMenu()
        statusMenu.delegate = self
        
        shortcutManager = KeyboardShortcutManager(menuBarManager: self)
        
        // Bildirimleri dinle (Başka yerden servis açmak için)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenServiceNotification(_:)),
            name: NSNotification.Name("OpenAIService"),
            object: nil
        )
        
        // Pencere dışına tıklayınca kapatma
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let window = self.popupWindow else { return }
            
            if window.isVisible {
                // Dosya seçici veya "Her zaman üstte" ayarı kontrolü
                if WebViewCache.shared.isFilePickerActive || PreferencesManager.shared.alwaysOnTop {
                    return
                }
                
                // Pencere dışına tıklandı mı?
                if !NSPointInRect(NSEvent.mouseLocation, window.frame) {
                    self.closePopupWindow()
                }
            }
        }
    }
    
    deinit {
        if let monitor = localEventMonitor { NSEvent.removeMonitor(monitor) }
        if let eventMonitor = eventMonitor { NSEvent.removeMonitor(eventMonitor) }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleStatusItemClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            statusItem.menu = statusMenu
            sender.performClick(nil)
            statusItem.menu = nil
        } else {
            if let window = popupWindow, window.isVisible {
                closePopupWindow()
            } else {
                openPopupWindow()
            }
        }
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        let openItem = NSMenuItem(
            title: "Open FloatBrowser",
            action: #selector(togglePopupWindow),
            keyEquivalent: "e"
        )
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // AIService.allCases kullanarak menü oluşturma
        for (index, service) in AIService.allCases.enumerated() {
            let keyEquivalent = index < 9 ? "\(index + 1)" : ""
            
            let item = NSMenuItem(
                title: service.name,
                action: #selector(openSpecificService(_:)),
                keyEquivalent: keyEquivalent
            )
            item.target = self
            // Hata veren kısım düzeltildi: NSEvent.ModifierFlags ekledi
            item.keyEquivalentModifierMask = [NSEvent.ModifierFlags.option, NSEvent.ModifierFlags.command]
            
            item.representedObject = service // Servisi sakla
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = NSApp
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc func togglePopupWindow() {
        if let window = popupWindow, window.isVisible {
            closePopupWindow()
        } else {
            openPopupWindow()
        }
    }
    
    @objc func openSpecificService(_ sender: NSMenuItem) {
        if let service = sender.representedObject as? AIService {
            openPopupWindow(with: service)
        }
    }
    
    @objc func handleOpenServiceNotification(_ notification: Notification) {
        if let service = notification.object as? AIService {
            openPopupWindow(with: service)
        }
    }
    
    func openPopupWindow(with service: AIService? = nil) {
        if let window = popupWindow {
            if !window.isVisible {
                showWindow(window)
            }
            // Eğer belirli bir servis istendiyse oraya git
            // Not: View tarafı state olduğu için burada zor olabilir,
            // ancak CompactChatView her açılışta state'i kontrol edebilir.
            return
        }
        
        // Pencere boyutları
        let windowSize = NSSize(width: 400, height: 600)
        let screenSize = NSScreen.main?.visibleFrame ?? NSRect.zero
        let rect = NSMakeRect(
            screenSize.midX - windowSize.width / 2,
            screenSize.midY - windowSize.height / 2,
            windowSize.width,
            windowSize.height
        )
        
        let window = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Pencere ayarları
        window.title = "FloatBrowser"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.delegate = self // Hata veren windowShouldMiniaturize fonksiyonunu sildik
        
        // HATA DUZELTME: closeAction parametresi eklendi
        let contentView = CompactChatView(
            initialService: service ?? .gemini,
            services: AIService.allCases,
            closeAction: { [weak self] in
                self?.closePopupWindow()
            }
        )
        
        window.contentView = NSHostingView(rootView: contentView)
        
        self.popupWindow = window
        showWindow(window)
    }
    
    private func showWindow(_ window: NSWindow) {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1
        }
    }
    
    func closePopupWindow() {
        guard let window = popupWindow else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            window.animator().alphaValue = 0
        }) {
            window.orderOut(nil)
            // Pencereyi tamamen yok etmiyoruz, bir dahaki sefere hızlı açılsın
            // Ancak bellek sorunu olursa self.popupWindow = nil yapılabilir
        }
    }
    
    // Pencere odak kaybettiğinde (Alternatif kapanma yöntemi)
    func windowDidResignKey(_ notification: Notification) {
        if !PreferencesManager.shared.alwaysOnTop && !WebViewCache.shared.isFilePickerActive {
            closePopupWindow()
        }
    }
}
