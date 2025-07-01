import Foundation
import SwiftData

@Model
class Book {
    /// タイトル
    var title: String
    /// 既読か
    var isRead: Bool
    /// アプリでの登録日
    var created: Date

    init(title: String, isRead: Bool, created: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.created = created
    }
}
