import SwiftUI
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

// TODO: サイズに合わせてViewを変更する
struct UnreadWidgetEntryView: View {
    private let maxVisibleBooks = 3

    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: UnreadProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(.progressOnUnreadBooks)
                .font(.headline)
                .padding(.bottom, 8)
            if entry.books.isEmpty {
                bookEmptyView()
                Spacer()
            } else {
                booksView()
                bookDummyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bookEmptyView() -> some View {
        Text(.iHaveNoUnreadBooks)
            .font(.body)
            .foregroundColor(.secondary)
    }

    private func booksView() -> some View {
        ForEach(entry.books.prefix(maxVisibleBooks).enumerated(), id: \.offset) { offset, book in
            ZStack(alignment: .bottom) {
                bookView(book)
                    .frame(maxHeight: .infinity, alignment: .center)
                Divider()
            }
        }
    }

    private func bookView(_ book: CodableBook) -> some View {
        HStack {
            Text(book.title)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(book.progressText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func bookDummyView() -> some View {
        if entry.books.count < maxVisibleBooks {
            let dummyViewCount = maxVisibleBooks - entry.books.count
            ForEach(0..<dummyViewCount, id: \.self) { _ in
                Color.clear
            }
        } else {
            EmptyView()
        }
    }
}

struct UnreadWidget: Widget {
    let kind: String = "UnreadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UnreadProvider()) { entry in
            UnreadWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(.trackingUnreadBooks)
        .description(.youCanCheckTheProgressOfYourUnreadBooks)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    UnreadWidget()
} timeline: {
    let books = [
        CodableBook(title: "Harry Potter", currentPage: 10, maxPage: 100),
        CodableBook(title: "ONE PIECE 1"),
        CodableBook(title: "パンどろぼう"),
    ]
    UnreadWidgetEntry(date: .now, books: books)
    UnreadWidgetEntry(date: .now, books: [])
}
