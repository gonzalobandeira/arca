import SwiftUI

struct ContentView: View {
    @State private var isUnlocked = false
    
    var body: some View {
        Group {
            if isUnlocked {
                DashboardView()
                    .transition(.opacity)
            } else {
                UnlockView(isUnlocked: $isUnlocked)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isUnlocked)
    }
}
