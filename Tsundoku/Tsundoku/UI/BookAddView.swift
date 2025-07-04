import SwiftData
import SwiftUI

struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var didInputedTitle = false
    @State private var isRead = false
    @State private var currentPage = ""
    @State private var maxPage = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Title")
                TextField("", text: $title)
                    .textFieldStyle(.roundedBorder)
                if title.isEmpty, didInputedTitle {
                    Text("Please enter a title")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Toggle("Read status", isOn: $isRead)
                Text("Page")
                HStack {
                    TextField("", text: $currentPage)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    Text("/")
                    TextField("", text: $maxPage)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if title.isEmpty { return }
                        addBook(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
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
        .onChange(of: title) {
            didInputedTitle = true
        }
    }
}

extension BookAddView {
    private func addBook(title: String, isRead: Bool, currentPage: String, maxPage: String) {
        let currentPage = Int(currentPage)
        let maxPage = Int(maxPage)
        let newBook = Book(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
        modelContext.insert(newBook)
    }
}

#Preview {
    BookAddView()
        .modelContainer(for: Book.self, inMemory: true)
}
