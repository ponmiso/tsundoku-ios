import Foundation
import SwiftData

@Model
final class Book {
    /// タイトル
    var title: String
    /// 既読か
    var isRead: Bool
    /// アプリでの登録日
    var created: Date

    init(title: String, isRead: Bool = false, created: Date = .now) {
        self.title = title
        self.isRead = isRead
        self.created = created
    }
}
