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

        observe()
        setupNavigationBar()
        setupChildrenView()
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

    private func setupChildrenView() {
        let barcodeView = UIView()
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barcodeView)
        barcodeCaptureSession?.attachPreviewLayer(to: barcodeView)
        barcodeCaptureSession?.startRunning()

        NSLayoutConstraint.activate([
            barcodeView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            barcodeView.heightAnchor.constraint(equalToConstant: 100),
            barcodeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            barcodeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
        ])

        let button = UIButton(type: .system)
        button.setTitle("Enter ISBNs manually", for: .normal)
        button.addTarget(self, action: #selector(tappedAddISBNButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: barcodeView.bottomAnchor, constant: 100),
        ])
    }

    @objc func tappedAddISBNButton() {
        let alert = UIAlertController(title: nil, message: "Enter ISBN", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "9784780802047"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text else {
                return
            }
            self?.viewModel.didInputISBN(code: code)
            self?.showCode(code)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
