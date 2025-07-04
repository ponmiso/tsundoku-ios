import SwiftData
import SwiftUI

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var isPresentedBookAddView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    bookView(book)
                }
                .onDelete(perform: deleteBooks)
            }
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
    private func bookView(_ book: Book) -> some View {
        NavigationLink {
            BookDetailsView(book)
        } label: {
            HStack {
                Text(book.title)
                    .font(.body)
                    .lineLimit(1)
                Spacer()
                Text(book.isRead ? "Read" : "Not Read")
                    .font(.caption)
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
