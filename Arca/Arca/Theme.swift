import SwiftUI

struct Theme {
    static let background = Color(red: 0.96, green: 0.95, blue: 0.91) // Creamy logo background
    static let cardBackground = Color.white.opacity(0.8)
    static let accent = Color(red: 0.08, green: 0.12, blue: 0.16) // Dark navy/midnight blue from logo
    static let secondaryAccent = Color(red: 0.3, green: 0.4, blue: 0.5)
    static let textMain = Color(red: 0.08, green: 0.12, blue: 0.16) // Match navy accent
    static let textSecondary = Color(red: 0.4, green: 0.45, blue: 0.5)
    static let error = Color(red: 0.7, green: 0.1, blue: 0.1)
    
    static let gradientMain = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.98, green: 0.97, blue: 0.94), Color(red: 0.96, green: 0.95, blue: 0.91)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let premiumFont = "HelveticaNeue-Medium"
}

extension View {
    func premiumGlass() -> some View {
        self.background(Theme.cardBackground)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.accent.opacity(0.15), lineWidth: 1)
            )
    }
}
