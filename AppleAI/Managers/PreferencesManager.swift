import SwiftUI
import ServiceManagement
import Combine // <-- BU EKLENDİ (Hataların çözümü)

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @AppStorage("alwaysOnTop") var alwaysOnTop: Bool = false {
        didSet {
            updateWindowLevel()
        }
    }
    
    @AppStorage("opacity") var opacity: Double = 1.0 {
        didSet {
            updateWindowOpacity()
        }
    }
    
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            toggleLaunchAtLogin(launchAtLogin)
        }
    }
    
    init() {}
    
    private func updateWindowLevel() {
        NotificationCenter.default.post(name: NSNotification.Name("UpdateWindowConfig"), object: nil)
    }
    
    private func updateWindowOpacity() {
        NotificationCenter.default.post(name: NSNotification.Name("UpdateWindowConfig"), object: nil)
    }
    
    private func toggleLaunchAtLogin(_ enable: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enable {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        } else {
            let bundleId = Bundle.main.bundleIdentifier! as CFString
            SMLoginItemSetEnabled(bundleId, enable)
        }
    }
}
