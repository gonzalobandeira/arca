import XCTest
@testable import Arca

final class CoordinateCardTests: XCTestCase {
    
    func testCardValidation_WithEnoughData_IsValid() {
        var grid: [String: String] = [:]
        for i in 1...40 {
            grid["A\(i)"] = "123"
        }
        let card = CoordinateCard(bankName: "Test", grid: grid)
        
        XCTAssertTrue(card.isValidCard())
    }
    
    func testCardValidation_WithLittleData_IsInvalid() {
        let grid = ["A1": "123", "B2": "456"]
        let card = CoordinateCard(bankName: "Test", grid: grid)
        
        XCTAssertFalse(card.isValidCard())
    }
    
    func testCoordinateCount_MatchesGridSize() {
        let grid = ["A1": "123", "B2": "456", "C3": "789"]
        let card = CoordinateCard(bankName: "Test", grid: grid)
        
        XCTAssertEqual(card.coordinateCount, 3)
    }
    
    func testExampleCard_IsValid() {
        let card = CoordinateCard.example()
        XCTAssertTrue(card.isValidCard())
        XCTAssertEqual(card.coordinateCount, 100)
    }
}
