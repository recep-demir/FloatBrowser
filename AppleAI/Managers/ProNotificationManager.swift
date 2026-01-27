import Foundation
import SwiftUI // ObservableObject ve AppKit (NSAlert) için gerekli
import UserNotifications
import Combine

class ProNotificationManager: ObservableObject {
    static let shared = ProNotificationManager()
    
    // ProManager'a erişim
    private var proManager: ProManager { ProManager.shared }
    
    private init() {
        // Otomatik izin iste
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Bildirim izni verildi.")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Basit bir bildirim gönderme fonksiyonu
    func sendProNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
