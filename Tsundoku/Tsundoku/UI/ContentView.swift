import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        Text(book.title)
                    } label: {
                        bookView(book)
                    }
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
    }
}

extension ContentView {
    private func bookView(_ book: Book) -> some View {
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

extension ContentView {
    private func addBook() {
        withAnimation {
            let newBook = Book(title: "xxx")
            modelContext.insert(newBook)
        }
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
        return ContentView().modelContainer(container)
    } catch {
        return Text("プレビュー生成エラー: \(error.localizedDescription)")
    }
}
