import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ProUpgradeBanner: View {
    @ObservedObject var proManager = ProManager.shared
    @State private var showUpgradeSheet = false
    
    var body: some View {
        if !proManager.isProUser {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    
                    Text(ProManager.shared.getProStatusText())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if proManager.trialDaysRemaining > 0 {
                        Button("Upgrade to Pro") {
                            showUpgradeSheet = true
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .font(.caption)
                        .foregroundColor(.blue)
                    } else {
                        Button("Upgrade Now") {
                            ProManager.shared.openUpgradeURL()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(NSColor.separatorColor)),
                    alignment: .bottom
                )
                
                if proManager.isTrialExpired() {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 10))
                        
                        Text("Trial expired. Upgrade to continue using AppleAi Pro.")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                }
            }
            .sheet(isPresented: $showUpgradeSheet) {
                ProUpgradeSheet()
            }
        }
    }
}

struct ProUpgradeSheet: View {
    @Environment(\.dismiss) private var dismissAction
    @ObservedObject var proManager = ProManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Upgrade to AppleAi Pro")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Unlock unlimited access to all AI models and premium features")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ProFeatureRow(icon: "infinity", text: "Unlimited AI model access")
                ProFeatureRow(icon: "bolt.fill", text: "Priority processing")
                ProFeatureRow(icon: "lock.fill", text: "Advanced privacy controls")
                ProFeatureRow(icon: "gear", text: "Custom API integrations")
                ProFeatureRow(icon: "sparkles", text: "Exclusive Pro features")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismissAction()
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button("Upgrade Now") {
                    ProManager.shared.openUpgradeURL()
                    dismissAction()
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(6)
            }
        }
        .padding(30)
        .frame(width: 400, height: 500)
    }
}

struct ProFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    ProUpgradeBanner()
}
extension ProManager {
    // Indicates whether the user's trial has expired
    func isTrialExpired() -> Bool {
        return !isProUser && trialDaysRemaining <= 0
    }
    // Fallback status text used by ProUpgradeBanner when ProManager doesn't provide one
    func getProStatusText() -> String {
        if isProUser {
            return "You're Pro — Thanks for supporting!"
        } else if trialDaysRemaining > 0 {
            let days = trialDaysRemaining
            let dayWord = days == 1 ? "day" : "days"
            return "Free trial: \(days) \(dayWord) remaining"
        } else if isTrialExpired() {
            return "Trial expired — Upgrade to continue"
        } else {
            return "Unlock AppleAi Pro"
        }
    }

    // Opens the upgrade URL used by the app. Adjust the URL string if your backend differs.
    func openUpgradeURL() {
        let urlString = "https://appleai.app/pro"
        guard let url = URL(string: urlString) else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}

