import Foundation
import Combine
import SwiftUI

class DashboardViewModel: ObservableObject {
    private let storage: SecureStorageProtocol
    @Published var cards: [CoordinateCard] = []
    
    init(storage: SecureStorageProtocol = SecureStorage()) {
        self.storage = storage
        loadCards()
    }
    
    func loadCards() {
        self.cards = storage.load()
    }
    
    func add(_ card: CoordinateCard) {
        print("DEBUG: DashboardViewModel adding card: \(card.bankName)")
        var current = cards
        current.append(card)
        do {
            try storage.save(cards: current)
            self.cards = current
            print("DEBUG: DashboardViewModel successfully saved updated cards list (\(current.count) cards)")
        } catch {
            print("ERROR: DashboardViewModel failed to save cards: \(error.localizedDescription)")
        }
    }
    
    func delete(at offsets: IndexSet) {
        var current = cards
        current.remove(atOffsets: offsets)
        do {
            try storage.save(cards: current)
            self.cards = current
        } catch {
            print("ERROR: DashboardViewModel failed to delete card: \(error.localizedDescription)")
        }
    }
    
    func rename(card: CoordinateCard, newName: String) {
        guard !newName.isEmpty else { return }
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            var current = cards
            var updatedCard = card
            updatedCard.bankName = newName
            current[index] = updatedCard
            do {
                try storage.save(cards: current)
                self.cards = current
            } catch {
                print("ERROR: DashboardViewModel failed to rename card: \(error.localizedDescription)")
            }
        }
    }
}
