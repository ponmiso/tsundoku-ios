import AVFoundation
import Combine
import UIKit

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(book: Book)
}

class ScannerViewController: UIViewController {
    weak var delegate: ScannerViewControllerDelegate?

    private let viewModel = ScannerViewModel()
    private let captureSession = AVCaptureSession()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput)
        else {
            return
        }

        observe()
        setupNavigationBar()

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13]  // 対応バーコードタイプ
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        startScanning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
}

extension ScannerViewController {
    private func startScanning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    private func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension ScannerViewController {
    private func observe() {
        viewModel.didFetchBook
            .sink { [weak self] book in
                self?.dismiss(animated: true) { [weak self] in
                    self?.delegate?.didFind(book: book)
                }
            }
            .store(in: &cancellables)
        viewModel.didFailedFetchBook
            .sink { [weak self] error in
                self?.showAlert(error)
            }
            .store(in: &cancellables)
    }

    private func showAlert(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            startScanning()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension ScannerViewController {
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelTapped))
    }

    @objc func didCancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension ScannerViewController: @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let code = metadataObject.stringValue {
            stopScanning()
            viewModel.didFind(code: code)
        }
    }
}
