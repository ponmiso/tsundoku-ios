import Foundation
import SwiftData

@Model
final class Book {
    /// タイトル
    var title: String
    /// 既読か
    var isRead: Bool
    /// 現在ページ数
    var currentPage: Int?
    /// 最大ページ数
    var maxPage: Int?
    /// 登録日
    var created: Date
    /// 更新日
    var updated: Date

    init(title: String, isRead: Bool = false, currentPage: Int? = nil, maxPage: Int? = nil, created: Date = .now, updated: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.currentPage = currentPage
        self.maxPage = maxPage
        self.created = created
        self.updated = updated
    }
}

extension Book {
    var isUnread: Bool {
        !isRead
    }
}
