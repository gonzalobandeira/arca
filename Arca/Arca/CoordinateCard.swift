import Foundation

/// Represents a secure coordinate card.
struct CoordinateCard: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var bankName: String
    var timestamp: Date = Date()
    
    /// Grid storage: Key is "A1", "J10", etc. Value is the code "123".
    var grid: [String: String]
    
    /// Returns the number of coordinates stored.
    var coordinateCount: Int {
        return grid.count
    }
    
    /// Verifies if the card has a reasonable amount of data to be considered valid.
    /// Standard cards usually have 10 rows (1-10) and 8-10 columns (A-H/J), so ~80-100 items.
    /// We'll set a threshold of 40 to allow for smaller cards or partial scans, but warn below that.
    func isValidCard() -> Bool {
        return grid.count >= 40
    }
    
    static func example() -> CoordinateCard {
        var mockGrid: [String: String] = [:]
        let rows = 1...10
        let cols = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        
        for row in rows {
            for col in cols {
                mockGrid["\(col)\(row)"] = String(Int.random(in: 100...999))
            }
        }
        
        return CoordinateCard(bankName: "Demo Bank", grid: mockGrid)
    }
}
