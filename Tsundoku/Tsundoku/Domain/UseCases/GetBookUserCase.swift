@MainActor
protocol GetBookUserCaseProtocol {
    func execute(input: GetBookInputData) async throws -> GetBookOuptPutData
}

struct GetBookInputData {
    let isbn13: String
}

struct GetBookOuptPutData {
    /// タイトル
    var title: String
    /// 現在ページ数
    var currentPage: Int?
    /// 最大ページ数
    var maxPage: Int?
    /// 画像
    var image: BookImage?
}

struct GetBookUserCase: GetBookUserCaseProtocol {
    func execute(input: GetBookInputData) async throws -> GetBookOuptPutData {
        // ISBN-13は978か979始まり
        if input.isbn13.count != 13 {
            throw GetBookError.invalidCode(code: input.isbn13)
        }
        if !input.isbn13.hasPrefix("978") && !input.isbn13.hasPrefix("979") {
            throw GetBookError.invalidCode(code: input.isbn13)
        }

        let response = try await OpenBDAPI().getRepositories(isbn: input.isbn13)
        let maxPage = response.page
        let currentPage = maxPage == nil ? nil : 0
        let image: BookImage? =
            if let url = response.thumbnailUrl {
                BookImage.url(url)
            } else {
                nil
            }
        return GetBookOuptPutData(title: response.title ?? "", currentPage: currentPage, maxPage: maxPage, image: image)
    }
}
