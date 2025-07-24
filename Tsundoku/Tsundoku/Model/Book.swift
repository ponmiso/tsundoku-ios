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

    var progressText: String {
        if let progress, !isOverPage {
            "\(Int(progress * 100)) %"
        } else {
            "---"
        }
    }

    private var progress: Double? {
        guard let currentPage, let maxPage, maxPage > 0 else {
            return nil
        }
        return Double(currentPage) / Double(maxPage)
    }

    private var isOverPage: Bool {
        guard let currentPage, let maxPage else {
            return false
        }
        return currentPage > maxPage
    }
}
