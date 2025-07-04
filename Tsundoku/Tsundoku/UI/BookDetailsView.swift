import SwiftData
import SwiftUI

struct BookDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    @State private var book: Book

    @State private var title: String
    @State private var isRead: Bool

    @State private var isPresentedAlert = false
    @State private var updateAlertDetails: UpdateAlertDetails?

    init(_ book: Book) {
        self.book = book

        title = book.title
        isRead = book.isRead
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Title")
                TextField("", text: $title)
                    .textFieldStyle(.roundedBorder)
                Toggle("Read status", isOn: $isRead)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        updateBook(title: title, isRead: isRead)
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
    private func updateBook(title: String, isRead: Bool) {
        book.title = title
        book.isRead = isRead
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            updateAlertDetails = UpdateAlertDetails(message: "Please restart the application and try again.")
            isPresentedAlert = true
        }
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
