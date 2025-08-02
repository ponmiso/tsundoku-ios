import AVFoundation
import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    var onBarcodeScanned: (Book) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiNavigationController: UINavigationController, context: Context) {}

    class Coordinator: NSObject, @preconcurrency ScannerViewControllerDelegate {
        let parent: BarcodeScannerView

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        @MainActor func didFind(book: Book) {
            parent.onBarcodeScanned(book)
        }
    }
}

#Preview {
    BarcodeScannerView { book in
        print(book)
    }
}
