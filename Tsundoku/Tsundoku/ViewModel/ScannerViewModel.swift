import Combine
import Foundation

@MainActor
struct ScannerViewModel {
    let didFetchBook = PassthroughSubject<Book, Never>()
    let didFailedFetchBook = PassthroughSubject<Error, Never>()

    func didFind(code: String) {
        print("Found code: \(code)")

        // ISBN-13は978か979始まり
        if code.count != 13 {
            didFailedFetchBook.send(ScanError.invalidCode(code: code))
            return
        }
        if !code.hasPrefix("978") && !code.hasPrefix("979") {
            didFailedFetchBook.send(ScanError.invalidCode(code: code))
            return
        }

        Task {
            try await Task.sleep(for: .seconds(1))
            didFetchBook.send(Book(title: code))
        }
    }
}

extension ScannerViewModel {
    enum ScanError: Error, LocalizedError {
        case invalidCode(code: String)

        var errorDescription: String? {
            switch self {
            case let .invalidCode(code):
                return "Invalid barcode.Read codes beginning with 978 or 979.\nCodes read: \(code)"
            }
        }
    }
}
