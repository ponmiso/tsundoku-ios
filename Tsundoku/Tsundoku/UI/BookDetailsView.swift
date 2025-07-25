import SwiftData
import SwiftUI

struct BookDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    @State private var book: Book

    @State private var title: String
    @State private var isRead: Bool
    @State private var currentPage: String
    @State private var maxPage: String

    @State private var isPresentedAlert = false
    @State private var updateAlertDetails: UpdateAlertDetails?

    init(_ book: Book) {
        self.book = book

        title = book.title
        isRead = book.isRead
        currentPage =
            if let currentPage = book.currentPage {
                String(currentPage)
            } else {
                ""
            }
        maxPage =
            if let maxPage = book.maxPage {
                String(maxPage)
            } else {
                ""
            }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Book Information")
                    .font(.headline)
                bookInfoView()

                Spacer().frame(height: 24)

                Text("Book Status")
                    .font(.headline)
                bookStatusView()

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        updateBook(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
                    }
                }
            }
        }
        .alert("Update failed", isPresented: $isPresentedAlert, presenting: updateAlertDetails) { _ in
            Button("OK") {}
        } message: { details in
            Text(details.message)
        }

    }
}

extension BookDetailsView {
    private func bookInfoView() -> some View {
        VStack(alignment: .leading) {
            Text("Title")
            TextField("Harry Potter", text: $title)
                .textFieldStyle(.roundedBorder)
            if title.isEmpty {
                Text("Please enter a title")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func bookStatusView() -> some View {
        VStack(alignment: .leading) {
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
            Text("Progress: \(progressText)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            if isOverPage {
                Text("Do not exceed the maximum number of pages")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension BookDetailsView {
    private func updateBook(title: String, isRead: Bool, currentPage: String, maxPage: String) {
        if title.isEmpty || isOverPage { return }

        book.title = title
        book.isRead = isRead
        book.currentPage = Int(currentPage)
        book.maxPage = Int(maxPage)
        book.updated = .now
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            updateAlertDetails = UpdateAlertDetails(message: "Please restart the application and try again.")
            isPresentedAlert = true
        }
    }
}

extension BookDetailsView {
    private var progress: Double? {
        guard let currentPage = Double(currentPage), let maxPage = Double(maxPage), maxPage > 0 else {
            return nil
        }
        return currentPage / maxPage
    }

    private var progressText: String {
        if let progress, !isOverPage {
            "\(Int(progress * 100)) %"
        } else {
            "---"
        }
    }

    private var isOverPage: Bool {
        currentPage > maxPage
    }
}

struct UpdateAlertDetails: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    let book = Book(title: "Test Book")
    return BookDetailsView(book)
        .modelContainer(for: Book.self, inMemory: true)
}
