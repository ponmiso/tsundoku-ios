import SwiftUI
import WidgetKit

struct UnreadWidgetView: View {
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
        ForEach(Array(entry.books.prefix(maxVisibleBooks).enumerated()), id: \.offset) { offset, book in
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
