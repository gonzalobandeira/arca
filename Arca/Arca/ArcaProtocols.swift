import Foundation
import UIKit

protocol OCRServiceProtocol {
    func processImage(_ image: UIImage) async throws -> CoordinateCard
}

protocol SecureStorageProtocol {
    func save(cards: [CoordinateCard]) throws
    func load() -> [CoordinateCard]
    func clear()
}

protocol BiometricServiceProtocol {
    var isAuthenticated: Bool { get }
    var authError: String? { get }
    func authenticateUser() async throws -> Bool
}
