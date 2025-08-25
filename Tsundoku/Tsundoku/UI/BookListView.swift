import SwiftData
import SwiftUI

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.updated, order: .reverse) private var books: [Book]
    @State private var isPresentedBookAddView = false
    @State private var isPresentedDeleteBookAlert = false
    @State private var deleteBook: DeletedBook?
    @State private var searchText = ""

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
    private var searchedBooks: [Book] {
        books
            .filter {
                if !searchText.isEmpty {
                    $0.title.contains(searchText)
                } else {
                    true
                }
            }
    }

    private var readBooks: [Book] {
        searchedBooks.filter(\.isRead)
    }

    private var unreadBooks: [Book] {
        searchedBooks.filter(\.isUnread)
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
                    bookSectionView(name: "Unread", books: unreadBooks)
                    bookSectionView(name: "Read", books: readBooks)
                }
            }
        }
    }
}

extension BookListView {
    private func bookSectionView(name: LocalizedStringKey, books: [Book]) -> some View {
        Section(name) {
            if books.isEmpty {
                bookEmptyView()
            } else {
                ForEach(books) { book in
                    bookView(book)
                }
                .onDelete {
                    onDeleteBooks(at: $0, in: books)
                }
            }
        }
    }

    private func bookView(_ book: Book) -> some View {
        NavigationLink {
            BookDetailsView(book)
        } label: {
            HStack {
                BookImageView(image: book.image)
                    .frame(width: 80, height: 80)
                Text(book.title)
                    .font(.body)
                    .lineLimit(3)
                Spacer()
                if book.isUnread {
                    Text("progress: \(book.progressText)")
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
    private func addBook() {
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
}

struct DeletedBook {
    let offsets: IndexSet
    let books: [Book]
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
