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
    /// アプリでの登録日
    var created: Date

    init(title: String, isRead: Bool = false, currentPage: Int? = nil, maxPage: Int? = nil, created: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.currentPage = currentPage
        self.maxPage = maxPage
        self.created = created
    }
}
