import SwiftUI

struct ProUpgradePrompt: View {
    @ObservedObject private var proManagerWrapper = ProManager.shared
    private var proManager: ProManager { proManagerWrapper }
    @State private var showPrompt = false
    
    var body: some View {
        EmptyView()
            .onAppear {
                checkAndShowPrompt()
            }
            .sheet(isPresented: $showPrompt) {
                ProUpgradeSheet()
            }
    }
    
    private func checkAndShowPrompt() {
        if proManager.shouldShowUpgradePrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showPrompt = true
                proManager.markUpgradePromptShown()
            }
        }
    }
}
