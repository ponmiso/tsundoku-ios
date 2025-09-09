import SwiftUI

@MainActor
struct BookTopViewRooter {
    @ViewBuilder
    func coordinator(_ screen: BookTopScreen) -> some View {
        switch screen {
        case let .bookDetail(book):
            BookDetailsView(book)
        case let .bookList(isRead):
            BookListView(isRead: isRead)
        }
    }
}
