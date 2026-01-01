import LocalAuthentication
import LocalAuthentication
import SwiftUI
import Combine

class BiometricService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var error: String? = nil
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        // Check if device supports biometrics
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to access your secure cards."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        // If biometric fails, we can fall back to device passcode
                        self.authenticateWithPasscode(context: context)
                    }
                }
            }
        } else {
            // No biometrics available, fall back to passcode
            DispatchQueue.main.async {
                self.authenticateWithPasscode(context: context)
            }
        }
    }
    
    private func authenticateWithPasscode(context: LAContext) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter device passcode to access") { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                } else {
                    self.error = error?.localizedDescription ?? "Authentication failed"
                }
            }
        }
    }
}
