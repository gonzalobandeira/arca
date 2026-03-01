import SwiftUI
import AVFoundation
import Vision
import VisionKit
import Combine

struct ScannerView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (CoordinateCard) -> Void

    @State private var tempCard: CoordinateCard?
    @State private var showingSourceSelection = true
    @State private var showingNativeScanner = false
    @State private var showingPhotoPicker = false
    @State private var isProcessing = false
    @State private var errorMessage: String?

    private let ocrService = OCRService()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if isProcessing {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(Theme.accent)
                    Text("Processing Scan...")
                        .font(.headline)
                        .foregroundColor(Theme.textMain)
                }
            } else if let card = tempCard {
                // Review Screen
                NavigationView {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("Verify Scan")
                                .font(.custom(Theme.premiumFont, size: 22))
                                .foregroundColor(Theme.textMain)
                            Text("Found \(card.grid.count) coordinates")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()

                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                let sortedKeys = card.grid.keys.sorted { a, b in
                                    let rowA = a.first ?? " "
                                    let rowB = b.first ?? " "
                                    if rowA != rowB { return rowA < rowB }
                                    let colA = Int(a.dropFirst()) ?? 0
                                    let colB = Int(b.dropFirst()) ?? 0
                                    return colA < colB
                                }
                                ForEach(sortedKeys, id: \.self) { key in
                                    VStack(spacing: 4) {
                                        Text(key)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.accent)
                                        Text(card.grid[key] ?? "")
                                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                                            .foregroundColor(Theme.textMain)
                                    }
                                    .padding(10)
                                    .background(Theme.background)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                            .padding()
                        }

                        VStack(spacing: 12) {
                            Button(action: {
                                print("DEBUG: Save Card tapped")
                                self.onSave(card)
                            }) {
                                Text("Save Card")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accent)
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                self.tempCard = nil
                                self.showingSourceSelection = true
                            }) {
                                Text("Retake")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                    }
                    .navigationBarHidden(true)
                }
            } else if showingSourceSelection {
                // Source selection screen
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Add Card")
                            .font(.custom(Theme.premiumFont, size: 26))
                            .foregroundColor(Theme.textMain)
                        Text("Choose how to add your card")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 16) {
                        Button(action: {
                            showingSourceSelection = false
                            showingNativeScanner = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Scan Document")
                                        .font(.headline)
                                    Text("Use camera to scan your card")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(Theme.textMain)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            showingSourceSelection = false
                            showingPhotoPicker = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Choose from Library")
                                        .font(.headline)
                                    Text("Import an existing photo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(Theme.textMain)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
            } else {
                // Placeholder while waiting for scanner
                VStack {
                    Text("Starting Scanner...")
                        .foregroundColor(Theme.textMain)
                }
            }
        }
        .fullScreenCover(isPresented: $showingNativeScanner) {
            DocumentScannerView(didFinishWithScan: { scan in
                print("DEBUG: Scanner finished with \(scan.pageCount) pages")
                self.showingNativeScanner = false
                if scan.pageCount > 0 {
                    self.isProcessing = true
                    let image = scan.imageOfPage(at: 0)
                    Task {
                        await processImage(image)
                    }
                } else {
                    self.showingSourceSelection = true
                }
            }, didCancel: {
                self.showingNativeScanner = false
                self.showingSourceSelection = true
            })
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingPhotoPicker) {
            PhotoPickerView(didFinishWithImage: { image in
                print("DEBUG: Photo picker finished with image")
                self.showingPhotoPicker = false
                self.isProcessing = true
                Task {
                    await processImage(image)
                }
            }, didCancel: {
                self.showingPhotoPicker = false
                self.showingSourceSelection = true
            })
            .ignoresSafeArea()
        }
        .alert("Scan Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {
                errorMessage = nil
                showingSourceSelection = true
            }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private func processImage(_ image: UIImage) async {
        do {
            let card = try await ocrService.processImage(image)
            await MainActor.run {
                self.isProcessing = false
                self.tempCard = card
                print("DEBUG: OCR success, showing review with \(card.grid.count) items")
            }
        } catch {
            await MainActor.run {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
