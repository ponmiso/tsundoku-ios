enum BookTopScreen: Hashable {
    case bookDetail(Book)
    case bookList(isRead: Bool)
}
