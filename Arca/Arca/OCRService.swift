import Vision
import Foundation
import Vision
import Foundation
import UIKit
import Combine

struct TextObservation {
    let text: String
    let bbox: CGRect
}

class OCRService: OCRServiceProtocol, ObservableObject {
    
    func processImage(_ image: UIImage) async throws -> CoordinateCard {
        // The image comes from VNDocumentCameraViewController.
        // It is already Rect-Detected, Perspective-Corrected, and Cropped.
        // We act as if this image IS the Grid (10x10).
        
        guard let cgImage = image.cgImage else {
            throw ArcaError.ocrFailed("Invalid image data")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: ArcaError.ocrFailed(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ArcaError.ocrFailed("No results from Vision"))
                    return
                }
                
                // Parse using Fixed Mapping Logic
                if let parsedCard = self.parseObservations(observations, inImageSize: image.size) {
                    continuation.resume(returning: parsedCard)
                } else {
                    continuation.resume(throwing: ArcaError.ocrFailed("Not enough coordinates detected. Please ensure the card is well-lit and fully visible."))
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: ArcaError.ocrFailed(error.localizedDescription))
            }
        }
    }
    

    
    private func parseObservations(_ observations: [VNRecognizedTextObservation], inImageSize: CGSize) -> CoordinateCard? {
        // Vision coordinates are 0..1 relative to the image (0,0 bottom-left).
        
        // 1. DYNAMIC GRID DETECTION (The "Data Island")
        // We look for "Data Anchors" - specifically the 2-digit numbers.
        let dataAnchors = observations.filter { obs in
            let text = obs.topCandidates(1).first?.string.filter("0123456789".contains) ?? ""
            return text.count == 2
        }
        
        guard dataAnchors.count > 40 else { 
            print("DEBUG: Not enough 2-digit anchors found (\(dataAnchors.count)).")
            return nil 
        }
        
        // Strategy: Use the core cluster (IQR) to find the grid, ignoring labels like '10'
        let sortedX = dataAnchors.map { $0.boundingBox.midX }.sorted()
        let sortedY = dataAnchors.map { $0.boundingBox.midY }.sorted()
        
        // Remove top/bottom 5% outliers (like a '10' label at the very top or side)
        let lowIdx = Int(Double(sortedX.count) * 0.05)
        let highIdx = Int(Double(sortedX.count) * 0.95)
        
        let minX = sortedX[lowIdx]
        let maxX = sortedX[highIdx]
        let minY = sortedY[lowIdx]
        let maxY = sortedY[highIdx]
        
        // The data area is 10x10. If we have the 5th to 95th percentile, 
        // they cover approx 9 columns/rows. We expand slightly to get the full grid bounds.
        let gridWidth = (maxX - minX) * (10.0 / 9.0)
        let gridHeight = (maxY - minY) * (10.0 / 9.0)
        
        let gridArea = CGRect(
            x: minX - (gridWidth * 0.05), // Shift half-column left
            y: minY - (gridHeight * 0.05), // Shift half-row down
            width: gridWidth,
            height: gridHeight
        )
        
        // Calibration: Divide this focused area into 10x10
        let colWidth = gridArea.width / 10.0
        let rowHeight = gridArea.height / 10.0
        
        var grid: [String: String] = [:]
        let rowLabels = ["J", "I", "H", "G", "F", "E", "D", "C", "B", "A"] // Bottom to Top
        
        for obs in observations {
            guard let topCandidate = obs.topCandidates(1).first else { continue }
            let txt = topCandidate.string.filter { "0123456789".contains($0) }
            guard !txt.isEmpty && txt.count <= 6 else { continue }
            
            let cx = obs.boundingBox.midX
            let cy = obs.boundingBox.midY
            
            // Check if it's within our detected grid area (with a small buffer)
            guard cx >= gridArea.minX - 0.02 && cx <= gridArea.maxX + 0.02 &&
                  cy >= gridArea.minY - 0.02 && cy <= gridArea.maxY + 0.02 else {
                continue // Likely a label or noise outside the grid
            }
            
            // Map relative to GridArea
            let relX = (cx - gridArea.minX) / gridArea.width
            let relY = (cy - gridArea.minY) / gridArea.height
            
            let colIndex = Int(floor(relX * 10))
            let rowIndex = Int(floor(relY * 10))
            
            // Clamp and process
            if colIndex >= 0 && colIndex < 10 && rowIndex >= 0 && rowIndex < 10 {
                let rowChar = rowLabels[rowIndex]
                let key = "\(rowChar)\(colIndex + 1)"
                
                if txt.count == 4 {
                    let s1 = String(txt.prefix(2)); let s2 = String(txt.suffix(2))
                    grid[key] = s1
                    if colIndex + 1 < 10 { grid["\(rowChar)\(colIndex + 2)"] = s2 }
                } else {
                    grid[key] = txt
                }
            }
        }
        
        print("DEBUG: Found \(grid.count) coordinates via Data Island detection.")
        
        // Verification: If we found < 40 items, the "Island" might be wrong.
        if grid.count >= 10 {
            return CoordinateCard(bankName: "Scanned Card", grid: grid)
        }
        return nil
    }
}
