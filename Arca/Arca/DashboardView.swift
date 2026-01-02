import SwiftUI
import Combine

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @State private var showingScanner = false
    @State private var cardToRename: CoordinateCard?
    @State private var newName = ""
    @State private var showRenameAlert = false
    
    init(viewModel: DashboardViewModel = DashboardViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Arcav")
                            .font(.custom(Theme.premiumFont, size: 28))
                            .foregroundColor(Theme.textMain)
                        Spacer()
                        Button(action: { showingScanner = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.cards.isEmpty {
                        // Empty State
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "creditcard.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No Secure Cards")
                                .font(.title3)
                                .foregroundColor(Theme.textMain)
                            Text("Tap + to scan and add your first coordinate card")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Spacer()
                    } else {
                        // List of Cards
                        List {
                            ForEach(viewModel.cards) { card in
                                ZStack { // Wrapper to hide default disclosure indicator issues in some iOS versions custom styling
                                    NavigationLink(destination: CardDetailView(card: card)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(card.bankName)
                                                .font(.headline)
                                                .foregroundColor(Theme.textMain)
                                            Text("Added: \(card.timestamp, style: .date)")
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Theme.accent)
                                    }
                                    .padding()
                                    .background(Theme.cardBackground.opacity(0.6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                    )
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = viewModel.cards.firstIndex(where: { $0.id == card.id }) {
                                            viewModel.delete(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        cardToRename = card
                                        newName = card.bankName
                                        showRenameAlert = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .contextMenu {
                                    Button {
                                        cardToRename = card
                                        newName = card.bankName
                                        showRenameAlert = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        if let index = viewModel.cards.firstIndex(where: { $0.id == card.id }) {
                                            viewModel.delete(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScanner) {
                ScannerView(onSave: { newCard in
                    print("DEBUG: DashboardView received new card: \(newCard.bankName)")
                    viewModel.add(newCard)
                    showingScanner = false
                })
            }
            .alert("Rename Card", isPresented: $showRenameAlert) {
                TextField("New Name", text: $newName)
                Button("Save") {
                    if let card = cardToRename {
                        viewModel.rename(card: card, newName: newName)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
