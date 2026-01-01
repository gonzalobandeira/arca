import SwiftUI

struct UnlockView: View {
    @StateObject var biometricService = BiometricService()
    @Binding var isUnlocked: Bool
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.accent)
                    .padding(.bottom, 20)
                
                Text("Arca")
                    .font(.custom(Theme.premiumFont, size: 24))
                    .foregroundColor(Theme.textMain)
                
                if let error = biometricService.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                Button(action: {
                    biometricService.authenticateUser()
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
            biometricService.authenticateUser()
        }
        .onChange(of: biometricService.isAuthenticated) { authenticated in
            if authenticated {
                withAnimation {
                    isUnlocked = true
                }
            }
        }
    }
}
