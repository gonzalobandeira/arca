import SwiftUI

struct UnlockView: View {
    @StateObject var biometricService = BiometricService()
    @EnvironmentObject var securityManager: SecurityManager
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.accent)
                    .padding(.bottom, 20)
                
                Text("Arcav")
                    .font(.custom(Theme.premiumFont, size: 24))
                    .foregroundColor(Theme.textMain)
                
                if let error = biometricService.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                Button(action: {
                    Task {
                        try? await biometricService.authenticateUser()
                    }
                }) {
                    Text("Unlock")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.accent)
                        .cornerRadius(12)
                }
                .padding(.top, 40)
                .padding(.horizontal, 50)
            }
        }
        .onAppear {
            Task {
                try? await biometricService.authenticateUser()
            }
        }
        .onChange(of: biometricService.isAuthenticated) { authenticated in
            if authenticated {
                withAnimation {
                    securityManager.setAuthenticated(true)
                }
            }
        }
    }
}
