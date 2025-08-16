import Foundation

enum BookImage: Equatable, Codable {
    case url(URL)
    case filePath(URL)
}
