import Foundation

enum BookImage: Codable {
    case url(URL)
    case filePath(URL)
}
