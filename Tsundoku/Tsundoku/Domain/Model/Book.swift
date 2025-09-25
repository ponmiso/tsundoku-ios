import Foundation
import SwiftData

@Model
final class Book: BookProgress {
    /// タイトル
    var title: String
    /// 既読か
    var isRead: Bool
    /// 現在ページ数
    var currentPage: Int?
    /// 最大ページ数
    var maxPage: Int?
    /// 画像
    var image: BookImage?
    /// 登録日
    var created: Date
    /// 更新日
    var updated: Date

    init(title: String, isRead: Bool = false, currentPage: Int? = nil, maxPage: Int? = nil, image: BookImage? = nil, created: Date = .now, updated: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.currentPage = currentPage
        self.maxPage = maxPage
        self.image = image
        self.created = created
        self.updated = updated
    }
}

extension Book {
    var isUnread: Bool {
        !isRead
    }
}

/// SwiftDataのModelはCodableに準拠しない方が良いので、同じ構造の構造体を用意する
struct CodableBook: Codable, BookProgress {
    /// タイトル
    let title: String
    /// 既読か
    let isRead: Bool
    /// 現在ページ数
    let currentPage: Int?
    /// 最大ページ数
    let maxPage: Int?
    /// 画像
    let image: BookImage?
    /// 登録日
    let created: Date
    /// 更新日
    let updated: Date

    init(book: Book) {
        self = CodableBook(title: book.title, isRead: book.isRead, currentPage: book.currentPage, maxPage: book.maxPage, image: book.image, created: book.created, updated: book.updated)
    }

    init(title: String, isRead: Bool = false, currentPage: Int? = nil, maxPage: Int? = nil, image: BookImage? = nil, created: Date = .now, updated: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.currentPage = currentPage
        self.maxPage = maxPage
        self.image = image
        self.created = created
        self.updated = updated
    }
}
