import Combine
import Foundation
import PhotosUI
import SwiftData
import SwiftUI

@MainActor
final class BookAddViewModel: ObservableObject {
    typealias FetchBookErrorReason = BookAddFetchBookErrorReason

    private let getBookUseCase: GetBookUserCaseProtocol
    private var isFetching = false
    private var boundIsbn13: String?

    @Published var image: BookImage?
    @Published var title = ""
    @Published var didInputedTitle = false
    @Published var isRead = false
    @Published var currentPage = ""
    @Published var maxPage = ""

    @Published var isPresentedScanner = false
    @Published var isPresentedPhotosPicker = false
    @Published var selectedPickerItem: PhotosPickerItem?
    @Published var isPresentedFetchBookErrorAlert = false
    @Published var fetchBookErrorReason: FetchBookErrorReason?

    @Published var actionPublisher: PassthroughSubject<Action, Never> = .init()

    init(isbn13: String? = nil, getBookUseCase: GetBookUserCase = GetBookUserCase()) {
        boundIsbn13 = isbn13
        self.getBookUseCase = getBookUseCase
    }
}

extension BookAddViewModel {
    func onTapScanner() {
        isPresentedScanner = true
    }

    func onTapAdd(context: ModelContext) {
        addBook(context: context, title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage, image: image)
    }

    func onTapCancel() {
        actionPublisher.send(.dismiss)
    }

    func onTapThumbnail() {
        isPresentedPhotosPicker = true
    }

    func task() async {
        guard let boundIsbn13 else { return }
        await fetchBook(code: boundIsbn13)
        self.boundIsbn13 = nil
    }
}

extension BookAddViewModel {
    func onChangeTitle() {
        didInputedTitle = true
    }

    func onChangePhotosPickerItem(_ item: PhotosPickerItem?) {
        Task {
            guard let item else {
                return
            }
            let data = try? await item.loadTransferable(type: Data.self)
            guard let data else {
                return
            }
            let url = try? await BookImageFileManager().saveTempPhotosPickerItem(data)
            guard let url else {
                return
            }
            image = .filePath(url)
        }
    }
}

extension BookAddViewModel {
    private func addBook(context: ModelContext, title: String, isRead: Bool, currentPage: String, maxPage: String, image: BookImage?) {
        if title.isEmpty || isOverPage { return }

        // 端末の画像が選択されている場合は、アプリ領域に永続的に画像を保存してそのファイルパスを保存する
        let newImage: BookImage?
        if let image, case let .filePath(url) = image {
            do {
                let newURL = try BookImageFileManager().moveToFile(from: url)
                newImage = BookImage.filePath(newURL)
            } catch {
                // TODO: アラート表示してそのまま保存するかどうか選ばせる
                newImage = nil
            }
        } else {
            newImage = nil
        }

        let currentPage = Int(currentPage)
        let maxPage = Int(maxPage)
        let newBook = Book(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage, image: newImage)
        context.insert(newBook)

        actionPublisher.send(.dismiss)
    }

    private func fetchBook(code: String) async {
        if isFetching {
            return
        }
        isFetching = true

        do {
            let input = GetBookInputData(isbn13: code)
            let output = try await getBookUseCase.execute(input: input)
            image = output.image
            title = output.title
            currentPage = String(output.currentPage)
            maxPage = String(output.maxPage)
            isFetching = false
        } catch {
            fetchBookErrorReason = FetchBookErrorReason(error: error)
            isPresentedFetchBookErrorAlert = true
            isFetching = false
        }
    }
}

extension BookAddViewModel {
    var shouldShowTitleError: Bool {
        title.isEmpty && didInputedTitle
    }

    var isOverPage: Bool {
        guard let currentPage = Double(currentPage), let maxPage = Double(maxPage) else {
            return false
        }
        return currentPage > maxPage
    }
}

extension BookAddViewModel {
    enum Action {
        case dismiss
    }
}
