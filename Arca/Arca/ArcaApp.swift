import SwiftUI

@main
struct ArcaApp: App {
    
    init() {
    }
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var securityManager = SecurityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(securityManager)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                securityManager.appMovedToBackground()
            } else if newPhase == .active {
                securityManager.appMovedToForeground()
            }
        }
    }
}
