import SwiftData
import SwiftUI

struct BookTopView: View {
    typealias DeletedBook = BookTopDeletedBook
    typealias Screen = BookTopScreen

    private let maxVisibleBooks = 3

    @StateObject var shortcutActionState = ShortcutActionState.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.updated, order: .reverse) private var books: [Book]

    @State private var presentedScreen: [Screen] = []
    @State private var isPresentedBookAddView = false
    @State private var isbn13ForBookAddView: String?
    @State private var isPresentedDeleteBookAlert = false
    @State private var deleteBook: DeletedBook?
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $presentedScreen) {
            contentView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: onAddBook) {
                            Label("Add Book", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: Screen.self) { screen in
                    BookTopViewRooter().coordinator(screen)
                }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isPresentedBookAddView) {
            BookAddView(isbn13: isbn13ForBookAddView)
        }
        .onChange(
            of: isPresentedBookAddView,
            { oldValue, newValue in
                // 画面が閉じられた時に、ショートカットから渡された値を初期化する
                if oldValue, !newValue {
                    isbn13ForBookAddView = nil
                }
            }
        )
        .alert("Do you really want to delete it?", isPresented: $isPresentedDeleteBookAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteBooks()
            }
        }
        .onAppear {
            coordinatorShortcutItem(shortcutActionState.shortcutItem)
        }
        .onChange(of: shortcutActionState.shortcutItem) {
            coordinatorShortcutItem(shortcutActionState.shortcutItem)
        }
    }
}

extension BookTopView {
    private var searchedBooks: ArraySlice<Book> {
        books
            .filter {
                if !searchText.isEmpty {
                    $0.title.contains(searchText)
                } else {
                    true
                }
            }
            .prefix(maxVisibleBooks)
    }

    private var readBooks: [Book] {
        searchedBooks.filter(\.isRead)
    }

    private var unreadBooks: [Book] {
        searchedBooks.filter(\.isUnread)
    }
}

extension BookTopView {
    private func contentView() -> some View {
        Group {
            if books.isEmpty {
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
                    bookSectionView(books: unreadBooks, isRead: false)
                    bookSectionView(books: readBooks, isRead: true)
                }
                // .navigationLinkIndicatorVisibility(.hidden) // TODO: Xcode26で使えそう
            }
        }
    }
}

extension BookTopView {
    private func bookSectionView(books: [Book], isRead: Bool) -> some View {
        Section(isRead ? "Read" : "Unread") {
            if books.isEmpty {
                bookEmptyView()
            } else {
                ForEach(books) { book in
                    bookView(book)
                }
                .onDelete {
                    onDeleteBooks(at: $0, in: books)
                }

                if books.count == maxVisibleBooks {
                    moreBookButton(isRead)
                }
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

    private func moreBookButton(_ isRead: Bool) -> some View {
        NavigationLink(value: Screen.bookList(isRead: isRead)) {
            Text("See more")
                .font(.body)
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }
}

extension BookTopView {
    private func onAddBook() {
        showBookAddView()
    }

    private func showBookAddView(_ isbn13: String? = nil) {
        isbn13ForBookAddView = isbn13
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
                if let bookImage, case let .filePath(url) = bookImage {
                    try? BookImageFileManager().removeFile(fileURL: url)
                }
            }
            self.deleteBook = nil
        }
    }

    private func coordinatorShortcutItem(_ item: ShortcutItem?) {
        switch item {
        case let .add(isbn13):
            presentedScreen.removeAll()
            showBookAddView(isbn13)

            shortcutActionState.setShortcutItem(from: nil)
        case .none:
            break
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

        // コンテナを環境に渡す
        return BookTopView().modelContainer(container)
    } catch {
        return Text("プレビュー生成エラー: \(error.localizedDescription)")
    }
}
