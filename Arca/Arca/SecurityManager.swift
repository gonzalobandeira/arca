import Foundation
import SwiftUI
import Combine

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    
    @Published var isAuthenticated = false
    private var lastBackgroundDate: Date?
    
    // Idle timeout in seconds (5 minutes)
    private let idleTimeout: TimeInterval = 300
    
    // For testing/debugging, we can set it to a shorter period
    #if DEBUG
    private let debugTimeout: TimeInterval = 10
    #endif

    private var currentTimeout: TimeInterval {
        #if DEBUG
        return debugTimeout
        #else
        return idleTimeout
        #endif
    }
    
    private init() {}
    
    func appMovedToBackground() {
        lastBackgroundDate = Date()
        print("DEBUG: App moved to background at \(lastBackgroundDate!)")
    }
    
    func appMovedToForeground() {
        guard let lastBackgroundDate = lastBackgroundDate else { return }
        
        let timeIdle = Date().timeIntervalSince(lastBackgroundDate)
        print("DEBUG: App moved to foreground. Time idle: \(timeIdle)s (Timeout: \(currentTimeout)s)")
        
        if timeIdle > currentTimeout {
            print("DEBUG: Session expired. Requirements re-authentication.")
            isAuthenticated = false
        }
        
        self.lastBackgroundDate = nil
    }
    
    func setAuthenticated(_ authenticated: Bool) {
        self.isAuthenticated = authenticated
    }
}
