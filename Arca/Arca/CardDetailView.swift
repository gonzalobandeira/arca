import SwiftUI

struct CardDetailView: View {
    let card: CoordinateCard
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 5) {
                    Text(card.bankName)
                        .font(.custom(Theme.premiumFont, size: 28))
                        .foregroundColor(Theme.textMain)

                }
                .padding(.top, 20)
                
                // Search Area
                VStack(spacing: 15) {
                    Text("Enter Coordinate")
                        .foregroundColor(Theme.textSecondary)
                        .font(.caption)
                        .textCase(.uppercase)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("e.g. A5", text: $searchText)
                            .foregroundColor(Theme.textMain)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            // Auto-uppercase input
                            .onChange(of: searchText) { newValue in
                                searchText = newValue.uppercased()
                            }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if !searchText.isEmpty {
                        if let code = card.grid[searchText] {
                            Text(code)
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(Theme.accent)
                                .shadow(color: Theme.accent.opacity(0.5), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                                .padding(.vertical, 20)
                        } else if validatedSearch(searchText) {
                            Text("NOT FOUND")
                                .foregroundColor(Theme.error)
                                .font(.headline)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .padding()
                .premiumGlass()
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                VStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.largeTitle)
                        .foregroundColor(Theme.accent.opacity(0.5))
                    Text("Your data is encrypted securely.")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary.opacity(0.6))
                }
                .padding(.bottom)
            }
        }
    }
    
    func validatedSearch(_ text: String) -> Bool {
        return text.count >= 2
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(card: CoordinateCard.example())
    }
}
