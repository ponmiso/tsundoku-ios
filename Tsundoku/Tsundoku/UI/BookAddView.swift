import PhotosUI
import SwiftData
import SwiftUI

struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var image: BookImage?
    @State private var title = ""
    @State private var didInputedTitle = false
    @State private var isRead = false
    @State private var currentPage = ""
    @State private var maxPage = ""

    @State private var isPresentedScanner = false
    @State private var isPresentedPhotosPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?

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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "barcode") {
                        isPresentedScanner = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addBook(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage, image: image)
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
        .sheet(isPresented: $isPresentedScanner) {
            BarcodeScannerView { book in
                image = book.image
                title = book.title
            }
        }
        .photosPicker(isPresented: $isPresentedPhotosPicker, selection: $selectedPickerItem, matching: .images)
        .onChange(of: selectedPickerItem) { _, newValue in
            onChangePhotosPickerItem(newValue)
        }
        .onChange(of: title) {
            didInputedTitle = true
        }
    }
}

extension BookAddView {
    private func bookInfoView() -> some View {
        VStack(alignment: .leading) {
            Text("Thumbnail")
            Button {
                isPresentedPhotosPicker = true
            } label: {
                BookImageView(image: image)
                    .frame(width: 120, height: 120)
            }

            Text("Title")
            TextField("Harry Potter", text: $title)
                .textFieldStyle(.roundedBorder)
            if title.isEmpty, didInputedTitle {
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
            if isOverPage {
                Text("Do not exceed the maximum number of pages")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension BookAddView {
    private func addBook(title: String, isRead: Bool, currentPage: String, maxPage: String, image: BookImage?) {
        if title.isEmpty || isOverPage { return }

        let currentPage = Int(currentPage)
        let maxPage = Int(maxPage)
        let newBook = Book(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage, image: image)
        modelContext.insert(newBook)
    }
}

extension BookAddView {
    private func onChangePhotosPickerItem(_ item: PhotosPickerItem?) {
        Task {
            guard let item else {
                return
            }
            let url = await saveTempPhotosPickerItem(item)
            guard let url else {
                return
            }
            image = .filePath(url)
        }
    }

    private func saveTempPhotosPickerItem(_ item: PhotosPickerItem) async -> URL? {
        let data = try? await item.loadTransferable(type: Data.self)
        guard let data else {
            return nil
        }
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("photo_\(timestamp).jpg")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
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
