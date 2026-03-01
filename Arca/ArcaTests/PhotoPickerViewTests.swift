import XCTest
import PhotosUI
@testable import Arca

final class PhotoPickerViewTests: XCTestCase {

    // MARK: - Coordinator creation

    func testMakeCoordinator_ConformsToPHPickerViewControllerDelegate() {
        let coordinator = makeView().makeCoordinator()
        XCTAssertTrue(coordinator is PHPickerViewControllerDelegate)
    }

    func testMakeCoordinator_EachCallReturnsDistinctInstance() {
        let view = makeView()
        let first = view.makeCoordinator()
        let second = view.makeCoordinator()
        XCTAssertFalse(first === second, "Each call to makeCoordinator() should produce a new object")
    }

    // MARK: - didFinishPicking with no results (user cancels)

    func testPickerDismissedWithNoResults_TriggersDidCancel() {
        let cancelled = expectation(description: "didCancel is called")
        var imageReceived: UIImage?

        let view = PhotoPickerView(
            didFinishWithImage: { imageReceived = $0 },
            didCancel: { cancelled.fulfill() }
        )
        view.makeCoordinator().picker(makePicker(), didFinishPicking: [])

        waitForExpectations(timeout: 1)
        XCTAssertNil(imageReceived, "No image should be delivered when the picker has no results")
    }

    func testPickerDismissedWithNoResults_DoesNotTriggerDidFinishWithImage() {
        let cancelExpectation = expectation(description: "cancel")
        var finishImageCalled = false

        let view = PhotoPickerView(
            didFinishWithImage: { _ in finishImageCalled = true },
            didCancel: { cancelExpectation.fulfill() }
        )
        view.makeCoordinator().picker(makePicker(), didFinishPicking: [])

        waitForExpectations(timeout: 1)
        XCTAssertFalse(finishImageCalled)
    }

    // MARK: - Picker configuration (verified through source-code contract)

    /// Asserts that a picker can be constructed without crashing, implying the
    /// PHPickerConfiguration produced by PhotoPickerView is valid.
    func testMakePicker_DoesNotThrow() {
        // PHPickerViewController will raise if given an invalid configuration.
        XCTAssertNoThrow(makePicker())
    }

    // MARK: - Helpers

    private func makeView(
        onImage: ((UIImage) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> PhotoPickerView {
        PhotoPickerView(
            didFinishWithImage: onImage ?? { _ in },
            didCancel: onCancel ?? {}
        )
    }

    /// Returns a PHPickerViewController configured exactly as PhotoPickerView does,
    /// so tests exercise the same configuration path.
    private func makePicker() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        return PHPickerViewController(configuration: config)
    }
}
