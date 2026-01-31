import SwiftUI
import WebKit

struct CompactChatView: View {
    @ObservedObject var menuManager: MenuBarManager
    let headerHeight: CGFloat = 28 // Sabit
    
    var body: some View {
        Group {
            if menuManager.isPinned {
                // --- PINLI HAL (PENCERE MODU) ---
                // YENİ YÖNTEM: OVERLAY
                GeminiWebView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Web içeriğini tam 28px aşağı itiyoruz
                    .padding(.top, headerHeight)
                    // Butonları 'overlay' ile ekliyoruz. Bu, layout sistemini bypass eder.
                    .overlay(
                        HStack(spacing: 12) {
                            Spacer() // Sola yasla
                            
                            // AOT Butonu
                            Button(action: { menuManager.toggleAlwaysOnTop() }) {
                                Image(systemName: menuManager.isAlwaysOnTop ? "square.stack.3d.up.fill" : "square.stack.3d.up")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(menuManager.isAlwaysOnTop ? .accentColor : .secondary)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Keep on Top")
                            
                            // Unpin Butonu
                            Button(action: { menuManager.togglePin() }) {
                                Image(systemName: "pin.slash.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Unpin to Menu Bar")
                        }
                        .padding(.trailing, 12)
                        .frame(height: headerHeight)
                        .background(Color.clear)
                        // Bu komut overlay'i en tepeye yapıştırır
                        , alignment: .top
                    )
                    // Pencerenin en üstüne taşmasını sağlar
                    .ignoresSafeArea(.all, edges: .top)
                
            } else {
                // --- FLOAT HALİ (POPOVER) ---
                VStack(spacing: 0) {
                    ZStack {
                        VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
                            .frame(height: 38) // Popover başlığı 38px (daha şık)
                        
                        HStack {
                            Button(action: { menuManager.togglePin() }) {
                                Image(systemName: "pin")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(6)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 12)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 38)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.gray.opacity(0.1)), alignment: .bottom)
                    
                    GeminiWebView()
                }
            }
        }
        .frame(minWidth: 350, minHeight: 500)
    }
}

// Yardımcılar
struct GeminiWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView { return WebViewCache.shared.getWebView() }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView(); view.material = material; view.blendingMode = blendingMode; view.state = .active; return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { nsView.material = material; nsView.blendingMode = blendingMode }
}
