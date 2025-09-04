import SwiftUI

@MainActor
struct BookListViewRooter {
    @ViewBuilder
    func coordinator(_ screen: BookListScreen) -> some View {
        switch screen {
        case let .bookDetail(book):
            BookDetailsView(book)
        }
    }
}
