import SwiftUI

struct ContentView: View {
    @EnvironmentObject var securityManager: SecurityManager
    
    var body: some View {
        Group {
            if securityManager.isAuthenticated {
                DashboardView()
                    .transition(.opacity)
            } else {
                UnlockView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: securityManager.isAuthenticated)
    }
}
