import Foundation
import Security

class SecureStorage {
    private let serviceName = "com.antigravity.arca.secure"
    private let accountName = "user_cards"
    
    func save(cards: [CoordinateCard]) -> Bool {
        guard let data = try? JSONEncoder().encode(cards) else { 
            print("ERROR: Could not encode cards to JSON")
            return false 
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName
        ]
        
        // Delete existing item first without data in query
        SecItemDelete(query as CFDictionary)
        
        var updateQuery = query
        updateQuery[kSecValueData as String] = data
        
        let status = SecItemAdd(updateQuery as CFDictionary, nil)
        if status != errSecSuccess {
            print("ERROR: Keychain SecItemAdd failed with status: \(status)")
        }
        return status == errSecSuccess
    }
    
    func load() -> [CoordinateCard] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            if let cards = try? JSONDecoder().decode([CoordinateCard].self, from: data) {
                return cards
            }
        }
        return []
    }
    
    func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName
        ]
        SecItemDelete(query as CFDictionary)
    }
}
