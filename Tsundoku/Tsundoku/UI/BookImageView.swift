import SwiftUI

struct BookImageView: View {
    let image: BookImage?

    var body: some View {
        switch image {
        case let .url(url):
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray
            }
        case .filePath:
            if let url = image?.existingURL, let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray
            }
        case .none:
            placeholder()
        }
    }
}

extension BookImageView {
    private func placeholder() -> some View {
        Image(systemName: "plus")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.black)
            .background(.gray)
    }
}

#Preview {
    if let url = URL(string: "https://cover.openbd.jp/9784780802047.jpg") {
        BookImageView(image: .url(url))
            .frame(width: 44, height: 44)
            .modelContainer(for: Book.self, inMemory: true)
    }
}

#Preview {
    BookImageView(image: nil)
}
