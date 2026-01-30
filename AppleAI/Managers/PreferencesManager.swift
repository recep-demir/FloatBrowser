import Foundation
import SwiftUI
import Combine
import ServiceManagement

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    // Zoom Seviyesi
    @AppStorage("zoomLevel") var zoomLevel: Double = 1.0
    
    // Başlangıçta Çalıştır
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet { toggleLaunchAtLogin(launchAtLogin) }
    }
    
    private init() {}
    
    private func toggleLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch { print("Launch error: \(error)") }
        }
    }
    
    // Zoom Artır
    func increaseZoom() {
        if zoomLevel < 3.0 {
            zoomLevel += 0.1
            // WebView'i anında güncelle
            WebViewCache.shared.updateZoom()
        }
    }
    
    // Zoom Azalt
    func decreaseZoom() {
        if zoomLevel > 0.5 {
            zoomLevel -= 0.1
            // WebView'i anında güncelle
            WebViewCache.shared.updateZoom()
        }
    }
}
