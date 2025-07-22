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
                TextField("Harry Potter", text: $title)
                    .textFieldStyle(.roundedBorder)
                if title.isEmpty, didInputedTitle {
                    Text("Please enter a title")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Toggle("Read status", isOn: $isRead)
                Text("Page")
                HStack {
                    TextField("10", text: $currentPage)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    Text("/")
                    TextField("100", text: $maxPage)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                if isOverPage {
                    Text("Do not exceed the maximum number of pages")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
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
        if title.isEmpty || isOverPage { return }

        let currentPage = Int(currentPage)
        let maxPage = Int(maxPage)
        let newBook = Book(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
        modelContext.insert(newBook)
    }
}

extension BookAddView {
    private var isOverPage: Bool {
        guard let currentPage = Double(currentPage), let maxPage = Double(maxPage) else {
            return false
        }
        return currentPage > maxPage
    }
}

#Preview {
    BookAddView()
        .modelContainer(for: Book.self, inMemory: true)
}
