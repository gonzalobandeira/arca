import LocalAuthentication
import LocalAuthentication
import SwiftUI
import Combine

class BiometricService: BiometricServiceProtocol, ObservableObject {
    @Published var isAuthenticated = false
    @Published var authError: String? = nil
    
    var error: String? { // Backward compatibility or internal use
        authError
    }
    
    func authenticateUser() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if device supports biometrics
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to access your secure cards."
            
            return try await withCheckedThrowingContinuation { continuation in
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                            continuation.resume(returning: true)
                        }
                    } else {
                        // If biometric fails, we can fall back to device passcode
                        self.authenticateWithPasscode(context: context, continuation: continuation)
                    }
                }
            }
        } else {
            // No biometrics available, fall back to passcode
            return try await withCheckedThrowingContinuation { continuation in
                self.authenticateWithPasscode(context: context, continuation: continuation)
            }
        }
    }
    
    private func authenticateWithPasscode(context: LAContext, continuation: CheckedContinuation<Bool, Error>) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter device passcode to access") { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    continuation.resume(returning: true)
                } else {
                    let errorMessage = error?.localizedDescription ?? "Authentication failed"
                    self.authError = errorMessage
                    continuation.resume(throwing: ArcaError.authenticationFailed(errorMessage))
                }
            }
        }
    }
}
