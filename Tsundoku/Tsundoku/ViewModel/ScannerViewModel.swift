import Combine
import Foundation

@MainActor
final class ScannerViewModel {
    let toggleScanning = PassthroughSubject<Bool, Never>()

    let didFetchBook = PassthroughSubject<Book, Never>()
    let didFailedFetchBook = PassthroughSubject<Error, Never>()

    private var isFetching = false

    func didFind(code: String) {
        print("Found code: \(code)")

        if isFetching {
            return
        }

        // ISBN-13は978か979始まり
        if code.count != 13 {
            return
        }
        if !code.hasPrefix("978") && !code.hasPrefix("979") {
            return
        }

        isFetching = true
        toggleScanning.send(false)

        Task {
            do {
                let response = try await OpenBDAPI().getRepositories(isbn: code)
                let maxPage = response.page
                let currentPage = maxPage == nil ? nil : 0
                didFetchBook.send(Book(title: response.title ?? "", currentPage: currentPage, maxPage: maxPage))
                isFetching = true
            } catch {
                didFailedFetchBook.send(error)
                isFetching = false
            }
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
