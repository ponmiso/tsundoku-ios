import SwiftUI

@MainActor
struct BookTopViewRooter {
    @ViewBuilder
    func coordinator(_ screen: BookTopScreen) -> some View {
        switch screen {
        case let .bookDetail(book):
            BookDetailsView(book)
        case .bookList:
            // TODO: 正式なViewに置き換える
            EmptyView()
        }
    }
}
