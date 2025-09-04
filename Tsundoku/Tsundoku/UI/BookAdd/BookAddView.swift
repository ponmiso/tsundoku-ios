import PhotosUI
import SwiftData
import SwiftUI

struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: BookAddViewModel

    init(isbn13: String? = nil) {
        let viewModel = BookAddViewModel(isbn13: isbn13)
        _viewModel = StateObject(wrappedValue: viewModel)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "barcode") {
                        viewModel.onTapScanner()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.onTapAdd(context: modelContext)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.onTapCancel()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentedScanner) {
            BarcodeScannerView { book in
                viewModel.image = book.image
                viewModel.title = book.title
            }
        }
        .photosPicker(isPresented: $viewModel.isPresentedPhotosPicker, selection: $viewModel.selectedPickerItem, matching: .images)
        .onChange(of: viewModel.selectedPickerItem) { _, newValue in
            viewModel.onChangePhotosPickerItem(newValue)
        }
        .onChange(of: viewModel.title) {
            viewModel.onChangeTitle()
        }
        .task {
            await viewModel.task()
        }
        .onReceive(viewModel.actionPublisher) { action in
            onReceiveAction(action)
        }
    }
}

extension BookAddView {
    private func bookInfoView() -> some View {
        VStack(alignment: .leading) {
            Text("Thumbnail")
            Button {
                viewModel.onTapThumbnail()
            } label: {
                BookImageView(image: viewModel.image)
                    .frame(width: 120, height: 120)
            }

            Text("Title")
            TextField("Harry Potter", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
            if viewModel.shouldShowTitleError {
                Text("Please enter a title")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func bookStatusView() -> some View {
        VStack(alignment: .leading) {
            Toggle("Read", isOn: $viewModel.isRead)
            Text("Page")
            HStack {
                TextField("", text: $viewModel.currentPage, prompt: Text(verbatim: "10"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Text(verbatim: "/")
                TextField("", text: $viewModel.maxPage, prompt: Text(verbatim: "100"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
            if viewModel.isOverPage {
                Text("Do not exceed the maximum number of pages")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension BookAddView {
    private func onReceiveAction(_ action: BookAddViewModel.Action) {
        switch action {
        case .dismiss:
            dismiss()
        }
    }
}

#Preview {
    BookAddView()
        .modelContainer(for: Book.self, inMemory: true)
}
