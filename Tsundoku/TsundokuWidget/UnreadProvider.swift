import WidgetKit

struct UnreadProvider: TimelineProvider {
    func placeholder(in context: Context) -> UnreadWidgetEntry {
        UnreadWidgetEntry(date: .now, books: placeholderBooks)
    }

    func getSnapshot(in context: Context, completion: @escaping (UnreadWidgetEntry) -> Void) {
        let entry = UnreadWidgetEntry(date: .now, books: unreadBooks)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UnreadWidgetEntry>) -> Void) {
        let entry = UnreadWidgetEntry(date: .now, books: unreadBooks)
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

extension UnreadProvider {
    private var placeholderBooks: [CodableBook] {
        [
            CodableBook(title: "Harry Potter", isRead: false),
            CodableBook(title: "ONE PIECE 1", isRead: false),
            CodableBook(title: "パンどろぼう", isRead: false),
        ]
    }

    private var unreadBooks: [CodableBook] {
        if let userDefaults = UserDefaultsManager.appGroupsUserDefaults,
            let unreadBooks = UserDefaultsManager(userDefaults: userDefaults).load(.unreadBooks),
            let _unreadBooks = unreadBooks as? [CodableBook]
        {
            _unreadBooks
        } else {
            []
        }
    }
}

struct UnreadWidgetEntry: TimelineEntry {
    let date: Date
    let books: [CodableBook]
}
