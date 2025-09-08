import Combine
import Foundation

@MainActor
final class ScannerViewModel {
    let didFetchBook = PassthroughSubject<Book, Never>()
    let didFailedFetchBook = PassthroughSubject<Error, Never>()

    private let getBookUseCase: GetBookUserCaseProtocol

    private var isFetching = false

    init(getBookUseCase: GetBookUserCase = GetBookUserCase()) {
        self.getBookUseCase = getBookUseCase
    }
}

extension ScannerViewModel {
    func didFind(code: String) {
        fetchBook(code: code)
    }

    func didInputISBN(code: String) {
        fetchBook(code: code)
    }

    private func fetchBook(code: String) {
        Task {
            if isFetching {
                return
            }
            isFetching = true
            defer { isFetching = false }

            do {
                let input = GetBookInputData(isbn13: code)
                let output = try await getBookUseCase.execute(input: input)
                didFetchBook.send(Book(title: output.title, currentPage: output.currentPage, maxPage: output.maxPage, image: output.image))
            } catch {
                if let bookError = error as? GetBookError, case .invalidCode = bookError {
                    return
                }
                didFailedFetchBook.send(error)
            }
        }
    }
}
