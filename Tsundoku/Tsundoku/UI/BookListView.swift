import SwiftData
import SwiftUI

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.updated, order: .reverse) private var books: [Book]
    @State private var isPresentedBookAddView = false

    var body: some View {
        NavigationStack {
            contentView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addBook) {
                            Label("Add Book", systemImage: "plus")
                        }
                    }
                }
        }
        .sheet(isPresented: $isPresentedBookAddView) {
            BookAddView()
        }
    }
}

extension BookListView {
    private var readBooks: [Book] {
        books.filter(\.isRead)
    }

    private var unreadBooks: [Book] {
        books.filter(\.isUnread)
    }
}

extension BookListView {
    private func contentView() -> some View {
        Group {
            if books.isEmpty {
                ContentUnavailableView {
                    Label("No Books", systemImage: "book")
                } description: {
                    Text("Please add the book")
                } actions: {
                    Button("Add Book", systemImage: "plus", action: addBook)
                        .padding(8)
                        .background(.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                List {
                    Section("Unread") {
                        ForEach(unreadBooks) { book in
                            bookView(book)
                        }
                        .onDelete(perform: deleteBooks)
                    }
                    Section("Read") {
                        ForEach(readBooks) { book in
                            bookView(book)
                        }
                        .onDelete(perform: deleteBooks)
                    }
                }
            }
        }
    }
}

extension BookListView {
    private func bookView(_ book: Book) -> some View {
        NavigationLink {
            BookDetailsView(book)
        } label: {
            HStack {
                Text(book.title)
                    .font(.body)
                    .lineLimit(1)
                Spacer()
                if book.isUnread {
                    Text("progress: \(book.progressText)")
                        .font(.caption)
                }
            }
        }
    }
}

extension BookListView {
    private func addBook() {
        isPresentedBookAddView = true
    }

    private func deleteBooks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(books[index])
            }
        }
    }
}

#Preview {
    do {
        // モック用の設定（inMemory: trueでオンメモリDB）
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Book.self, configurations: config)

        // モックデータ追加
        let context = container.mainContext
        context.insert(Book(title: "xxx"))

        // コンテナを環境に渡す
        return BookListView().modelContainer(container)
    } catch {
        return Text("プレビュー生成エラー: \(error.localizedDescription)")
    }
}
