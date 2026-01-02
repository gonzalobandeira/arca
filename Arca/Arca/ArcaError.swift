import Foundation

enum ArcaError: Error, LocalizedError {
    case ocrFailed(String)
    case storageFailed(String)
    case authenticationFailed(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .ocrFailed(let details):
            return "OCR failed: \(details)"
        case .storageFailed(let details):
            return "Storage failed: \(details)"
        case .authenticationFailed(let details):
            return "Authentication failed: \(details)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
