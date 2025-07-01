import SwiftData
import SwiftUI

struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Title")
                TextField("", text: $title)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addBook(title: title)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension BookAddView {
    private func addBook(title: String) {
        let newBook = Book(title: title)
        modelContext.insert(newBook)
    }
}

#Preview {
    BookAddView()
        .modelContainer(for: Book.self, inMemory: true)
}
