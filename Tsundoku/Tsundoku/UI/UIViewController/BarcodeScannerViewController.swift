import AVFoundation
import Combine
import UIKit

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(book: Book)
}

class ScannerViewController: UIViewController {
    weak var delegate: ScannerViewControllerDelegate?

    private let viewModel = ScannerViewModel()
    private let barcodeCaptureSession = BarcodeCaptureSession()

    private var codeLabel: UILabel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let barcodeCaptureSession else {
            return
        }

        observe()
        setupNavigationBar()

        barcodeCaptureSession.attachPreviewLayer(to: view)
        barcodeCaptureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodeCaptureSession?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodeCaptureSession?.stopRunning()
    }
}

extension ScannerViewController {
    private func observe() {
        viewModel.toggleScanning
            .sink { [weak self] isScanning in
                if isScanning {
                    self?.barcodeCaptureSession?.startRunning()
                } else {
                    self?.barcodeCaptureSession?.stopRunning()
                }
            }
            .store(in: &cancellables)
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

        barcodeCaptureSession?.codePublisher
            .sink { [weak self] code in
                self?.viewModel.didFind(code: code)
                self?.showCode(code)
            }
            .store(in: &cancellables)
    }

    private func showAlert(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            barcodeCaptureSession?.startRunning()
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

extension ScannerViewController {
    private func showCode(_ code: String) {
        if let codeLabel {
            if let text = codeLabel.text, text == code {
                return
            } else {
                codeLabel.isHidden = true
                codeLabel.removeFromSuperview()
            }
        }
        let label = defalutCodeLabel
        label.text = code
        view.addSubview(label)
        codeLabel = label

        label.alpha = 0
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1
        }
        UIView.animate(
            withDuration: 1.0, delay: 3.0,
            animations: {
                label.alpha = 0
            },
            completion: { _ in
                label.removeFromSuperview()
                self.codeLabel = nil
            })
    }

    private var defalutCodeLabel: UILabel {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .lightGray.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 24)

        let labelWidth: CGFloat = 300
        let labelHeight: CGFloat = 50
        let screenSize = UIScreen.main.bounds.size
        let x = max((screenSize.width - labelWidth) / 2, 0)
        let y = (screenSize.height - labelHeight - 100)
        label.frame = CGRect(x: x, y: y, width: labelWidth, height: labelHeight)
        return label
    }
}
