import XCTest
import Combine
@testable import Arca

class MockSecureStorage: SecureStorageProtocol {
    var savedCards: [CoordinateCard]?
    var mockCards: [CoordinateCard] = []
    
    func save(cards: [CoordinateCard]) throws {
        savedCards = cards
        mockCards = cards
    }
    
    func load() -> [CoordinateCard] {
        return mockCards
    }
    
    func clear() {
        mockCards = []
    }
}

final class DashboardViewModelTests: XCTestCase {
    var sut: DashboardViewModel!
    var mockStorage: MockSecureStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockSecureStorage()
        sut = DashboardViewModel(storage: mockStorage)
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }
    
    func testInitialState_IsEmpty() {
        XCTAssertTrue(sut.cards.isEmpty)
    }
    
    func testAddCard_UpdatesStorageAndState() {
        let card = CoordinateCard(bankName: "Test Bank", grid: ["A1": "123"])
        sut.add(card)
        
        XCTAssertEqual(sut.cards.count, 1)
        XCTAssertEqual(sut.cards.first?.bankName, "Test Bank")
        XCTAssertEqual(mockStorage.savedCards?.count, 1)
    }
    
    func testDeleteCard_UpdatesStorageAndState() {
        let card = CoordinateCard(bankName: "Test Bank", grid: ["A1": "123"])
        sut.add(card)
        XCTAssertEqual(sut.cards.count, 1)
        
        sut.delete(at: IndexSet(integer: 0))
        
        XCTAssertTrue(sut.cards.isEmpty)
        XCTAssertTrue(mockStorage.savedCards?.isEmpty ?? false)
    }
    
    func testRenameCard_UpdatesStorageAndState() {
        let card = CoordinateCard(bankName: "Old Name", grid: ["A1": "123"])
        sut.add(card)
        
        sut.rename(card: sut.cards[0], newName: "New Name")
        
        XCTAssertEqual(sut.cards.first?.bankName, "New Name")
        XCTAssertEqual(mockStorage.savedCards?.first?.bankName, "New Name")
    }
}
