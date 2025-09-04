import Foundation

enum BookImage: Equatable, Codable {
    case url(URL)
    case filePath(URL)
}

extension BookImage {
    var existingURL: URL? {
        switch self {
        case let .url(url):
            return url
        case let .filePath(fileURL):
            // パス内のUUIDが変わる可能性があるため、ファイルがなければアプリケーションディレクトリを探索する
            // また、tmpディレクトリをそのまま表示させるために、元のファイルの存在チェックをしている
            let fileManager = FileManager.default
            return if fileManager.fileExists(atPath: fileURL.path) {
                fileURL
            } else if let appURL = try? BookImageFileManager().fileURL(fileName: fileURL.lastPathComponent), fileManager.fileExists(atPath: appURL.path) {
                appURL
            } else {
                nil
            }
        }
    }
}
