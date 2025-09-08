@preconcurrency import AVFoundation
import Combine
import UIKit

final class BarcodeCaptureSession: NSObject {
    let framePublisher = PassthroughSubject<CGRect, Never>()
    let codePublisher = PassthroughSubject<String, Never>()

    private let captureSession: AVCaptureSession
    private let previewLayer: AVCaptureVideoPreviewLayer

    init?(metadataTypes: [AVMetadataObject.ObjectType] = [.ean13]) {
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            return nil
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            return nil
        }

        session.addOutput(output)

        self.captureSession = session
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()

        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = metadataTypes
    }

    @MainActor
    func attachPreviewLayer(to view: UIView) {
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    func startRunning() {
        Task.detached { [captureSession] in
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }

    func stopRunning() {
        Task.detached { [captureSession] in
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
}

extension BarcodeCaptureSession: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }

        let frame: CGRect =
            if let transformedObject = previewLayer.transformedMetadataObject(for: object) {
                transformedObject.bounds
            } else {
                .zero
            }
        framePublisher.send(frame)

        if let code = object.stringValue {
            codePublisher.send(code)
        }
    }
}
