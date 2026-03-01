import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    var didFinishWithImage: ((UIImage) -> Void)
    var didCancel: (() -> Void)

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) {
                guard let result = results.first else {
                    self.parent.didCancel()
                    return
                }
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    DispatchQueue.main.async {
                        if let image = object as? UIImage {
                            self.parent.didFinishWithImage(image)
                        } else {
                            self.parent.didCancel()
                        }
                    }
                }
            }
        }
    }
}
