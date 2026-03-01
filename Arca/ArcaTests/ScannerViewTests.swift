import XCTest
import UIKit
@testable import Arca

/// Tests for the shared OCR-processing path that both the camera scanner and the
/// camera-roll photo picker feed into inside ScannerView.
///
/// ScannerView uses SwiftUI @State and cannot be instantiated directly in XCTest
/// without a UI-testing host; therefore these tests target the OCRService layer
/// that backs the new `processImage(_:)` helper, covering the two outcomes
/// ScannerView has to handle: success and failure.
final class ScannerViewTests: XCTestCase {

    private var ocrService: OCRService!

    override func setUp() {
        super.setUp()
        ocrService = OCRService()
    }

    override func tearDown() {
        ocrService = nil
        super.tearDown()
    }

    // MARK: - processImage: failure paths (shared by camera and photo-picker sources)

    /// A completely blank (white) image carries no text; OCR must reject it.
    func testProcessImage_WithBlankImage_ThrowsOCRFailed() async {
        let blank = makeBlankImage(size: CGSize(width: 400, height: 300))

        do {
            _ = try await ocrService.processImage(blank)
            XCTFail("Expected an error to be thrown for a blank image")
        } catch let error as ArcaError {
            if case .ocrFailed = error {
                // Expected path
            } else {
                XCTFail("Expected ArcaError.ocrFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    /// A 1×1 pixel image has no useful content; OCR must reject it.
    func testProcessImage_WithTinyImage_ThrowsOCRFailed() async {
        let tiny = makeBlankImage(size: CGSize(width: 1, height: 1))

        do {
            _ = try await ocrService.processImage(tiny)
            XCTFail("Expected an error to be thrown for a 1×1 image")
        } catch let error as ArcaError {
            if case .ocrFailed = error {
                // Expected path
            } else {
                XCTFail("Expected ArcaError.ocrFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    /// An image whose CGImage backing has been corrupted should surface an ocrFailed error,
    /// not crash the app.
    func testProcessImage_WithInvalidCGImage_ThrowsOCRFailed() async {
        // UIImage() has no CGImage → the guard in processImage should fire.
        let empty = UIImage()

        do {
            _ = try await ocrService.processImage(empty)
            XCTFail("Expected ArcaError.ocrFailed for an image without CGImage data")
        } catch let error as ArcaError {
            if case .ocrFailed = error {
                // Expected path
            } else {
                XCTFail("Expected ArcaError.ocrFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - ArcaError: localised descriptions (used in ScannerView's alert)

    func testOCRFailedError_ContainsDetail() {
        let detail = "Not enough coordinates detected"
        let error = ArcaError.ocrFailed(detail)
        XCTAssertTrue(
            error.localizedDescription.contains(detail),
            "Localised description should include the detail string so ScannerView's alert is informative"
        )
    }

    func testOCRFailedError_LocalisedDescriptionIsNonEmpty() {
        let error = ArcaError.ocrFailed("some detail")
        XCTAssertFalse(error.localizedDescription.isEmpty)
    }

    // MARK: - CoordinateCard: model constraints enforced before saving

    /// ScannerView only calls onSave when the user approves the review screen.
    /// The card shown there may have fewer than 40 coordinates (partial scan),
    /// so isValidCard() is the gate – verify the model enforces it correctly.
    func testCard_BelowThreshold_IsNotValid() {
        let sparse = CoordinateCard(bankName: "Test", grid: ["A1": "12", "B2": "34"])
        XCTAssertFalse(sparse.isValidCard())
    }

    func testCard_AtThreshold_IsValid() {
        var grid: [String: String] = [:]
        for i in 1...40 { grid["A\(i)"] = "12" }
        let card = CoordinateCard(bankName: "Test", grid: grid)
        XCTAssertTrue(card.isValidCard())
    }

    func testCard_AboveThreshold_IsValid() {
        let card = CoordinateCard.example()     // 100 coordinates
        XCTAssertTrue(card.isValidCard())
        XCTAssertEqual(card.coordinateCount, 100)
    }

    // MARK: - Helpers

    private func makeBlankImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
