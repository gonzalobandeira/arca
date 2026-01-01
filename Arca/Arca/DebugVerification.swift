import SwiftUI

class DebugVerification {
    static func runVerification() {
        print("🔍 Starting Debug Verification...")
        
        // Ensure you add IMG_1713.jpg to your Xcode Project (Assets or Bundle)
        guard let image = UIImage(named: "IMG_1713") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "IMG_1713", ofType: "jpg") ?? "") else {
            print("⚠️ IMG_1713.jpg not found in Bundle. Please drag it into your Xcode project.")
            return
        }
        
        let ocr = OCRService()
        ocr.processImage(image) { card in
            if let card = card {
                print("✅ SUCESS: Card Extracted!")
                print("   Bank: \(card.bankName)")
                print("   Coordinates Found: \(card.grid.count)")
                print("   Example A1: \(card.grid["A1"] ?? "N/A")")
                print("   Example J10: \(card.grid["J10"] ?? "N/A")")
                print("   Valid: \(card.isValidCard())")
            } else {
                print("❌ FAILURE: Could not extract card data.")
            }
        }
    }
}
