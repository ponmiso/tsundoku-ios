import SwiftData
import SwiftUI

struct BookListView: View {
    typealias DeletedBook = BookTopDeletedBook
    typealias Screen = BookTopScreen

    private let isRead: Bool

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.updated, order: .reverse) private var books: [Book]
    private var displayBooks: [Book] {
        let searchedBooks =
            books
            .filter {
                if !searchText.isEmpty {
                    $0.title.contains(searchText)
                } else {
                    true
                }
            }
        return if isRead {
            searchedBooks.filter(\.isRead)
        } else {
            searchedBooks.filter(\.isUnread)
        }
    }

    @State private var isPresentedBookAddView = false
    @State private var isPresentedDeleteBookAlert = false
    @State private var deleteBook: DeletedBook?
    @State private var searchText = ""

    init(isRead: Bool) {
        self.isRead = isRead
    }

    var body: some View {
        contentView()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onAddBook) {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(isRead ? "Read" : "Unread")
            .searchable(text: $searchText)
            .sheet(isPresented: $isPresentedBookAddView) {
                BookAddView()
            }
            .alert("Do you really want to delete it?", isPresented: $isPresentedDeleteBookAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteBooks()
                }
            }
    }
}

extension BookListView {
    private func contentView() -> some View {
        Group {
            if displayBooks.isEmpty {
                ContentUnavailableView {
                    Label("No Books", systemImage: "book")
                } description: {
                    Text("Please add the book")
                } actions: {
                    Button("Add Book", systemImage: "plus", action: onAddBook)
                        .padding(8)
                        .background(.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                List {
                    bookSectionView()
                }
            }
        }
    }
}

extension BookListView {
    @ViewBuilder
    private func bookSectionView() -> some View {
        if displayBooks.isEmpty {
            bookEmptyView()
        } else {
            ForEach(displayBooks) { book in
                bookView(book)
            }
            .onDelete {
                onDeleteBooks(at: $0, in: displayBooks)
            }
        }
    }

    private func bookView(_ book: Book) -> some View {
        NavigationLink(value: Screen.bookDetail(book)) {
            HStack {
                BookImageView(image: book.image)
                    .frame(width: 80, height: 80)
                Text(book.title)
                    .font(.body)
                    .lineLimit(3)
                Spacer()
                if book.isUnread {
                    Text("Progress: \(book.progressText)")
                        .font(.caption)
                }
            }
        }
    }

    private func bookEmptyView() -> some View {
        Text("No Books")
            .font(.body)
            .lineLimit(1)
            .listRowBackground(Color.clear)
    }
}

extension BookListView {
    private func onAddBook() {
        showBookAddView()
    }

    private func showBookAddView() {
        isPresentedBookAddView = true
    }

    private func onDeleteBooks(at offsets: IndexSet, in books: [Book]) {
        deleteBook = DeletedBook(offsets: offsets, books: books)
        isPresentedDeleteBookAlert = true
    }

    private func deleteBooks() {
        guard let deleteBook else { return }
        withAnimation {
            for index in deleteBook.offsets {
                let bookImage = deleteBook.books[index].image
                modelContext.delete(deleteBook.books[index])

                // 削除に失敗しても動作に影響がないのでエラーは無視
                if let bookImage, case .filePath(let url) = bookImage {
                    try? BookImageFileManager().removeFile(fileURL: url)
                }
            }
            self.deleteBook = nil
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
        context.insert(Book(title: "xxx1"))
        context.insert(Book(title: "xxx2"))
        context.insert(Book(title: "xxx3"))
        context.insert(Book(title: "xxx4"))
        context.insert(Book(title: "xxx5"))
        context.insert(Book(title: "xxx6"))
        context.insert(Book(title: "xxx7"))

        // コンテナを環境に渡す
        return NavigationStack {
            BookListView(isRead: false).modelContainer(container)
        }
    } catch {
        return Text("プレビュー生成エラー: \(error.localizedDescription)")
    }
}
