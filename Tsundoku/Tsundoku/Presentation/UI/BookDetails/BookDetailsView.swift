import PhotosUI
import SwiftData
import SwiftUI

struct BookDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    /// SwiftDataに管理されているBook
    @State private var book: Book

    /// 表示用のプロパティ
    @State private var image: BookImage?
    @State private var title: String
    @State private var isRead: Bool
    @State private var currentPage: String
    @State private var maxPage: String

    @State private var isPresentedAlert = false
    @State private var updateAlertDetails: UpdateAlertDetails?
    @State private var isPresentedPhotosPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var isPresentedForceSaveAlert = false

    init(_ book: Book) {
        self.book = book

        image = book.image
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
                Button("Update") {
                    updateBook(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
                }
            }
        }
        .alert("Update failed", isPresented: $isPresentedAlert, presenting: updateAlertDetails) { _ in
            Button("OK") {}
        } message: { details in
            Text(details.message)
        }
        .alert("", isPresented: $isPresentedForceSaveAlert) {
            Button("Cancel") {}
            Button("Save") {
                Task {
                    // アラートを表示した後、すぐにアラートを表示することができないので、遅延を入れる
                    try? await Task.sleep(for: .seconds(0.1))
                    updateBookWithoutImage(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
                }
            }
        } message: {
            Text("Image update failed. Do you want to save without updating the image?")
        }
        .photosPicker(isPresented: $isPresentedPhotosPicker, selection: $selectedPickerItem, matching: .images)
        .onChange(of: selectedPickerItem) { _, newValue in
            onChangePhotosPickerItem(newValue)
        }
    }
}

extension BookDetailsView {
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
            if title.isEmpty {
                Text("Please enter a title")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func bookStatusView() -> some View {
        VStack(alignment: .leading) {
            Toggle("Read", isOn: $isRead)
            Text("Page")
            HStack {
                TextField("", text: $currentPage, prompt: Text(verbatim: "10"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Text(verbatim: "/")
                TextField("", text: $maxPage, prompt: Text(verbatim: "100"))
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

        // 画像が変更されている場合は画像を更新する
        if isChangedImage, let image, case .filePath(let url) = image {
            // 事前に古い画像パスを保持しておき、後で削除する
            let oldBookImage = book.image

            do {
                let newURL = try BookImageFileManager().moveToFile(from: url)
                book.image = BookImage.filePath(newURL)

                // 古い画像を削除する
                if case .filePath(let oldURL) = oldBookImage {
                    // 削除に失敗しても動作に影響がないのでエラーは無視
                    try? BookImageFileManager().removeFile(fileURL: oldURL)
                }
            } catch {
                isPresentedForceSaveAlert = true
                return
            }
        }

        updateBookWithoutImage(title: title, isRead: isRead, currentPage: currentPage, maxPage: maxPage)
    }

    private func updateBookWithoutImage(title: String, isRead: Bool, currentPage: String, maxPage: String) {
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

    private var isChangedImage: Bool {
        return switch (image, book.image) {
        case (let image1?, let image2?):
            image1 != image2
        case (nil, nil):
            false
        default:
            true
        }
    }
}

extension BookDetailsView {
    private func onChangePhotosPickerItem(_ item: PhotosPickerItem?) {
        Task {
            guard let item else {
                return
            }
            let data = try? await item.loadTransferable(type: Data.self)
            guard let data else {
                return
            }
            let url = try? await BookImageFileManager().saveTempPhotosPickerItem(data)
            guard let url else {
                return
            }
            image = .filePath(url)
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
