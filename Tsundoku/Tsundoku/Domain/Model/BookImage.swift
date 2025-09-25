import Foundation

enum BookImage: Equatable, Codable {
    case url(URL)
    case filePath(URL)
}

extension BookImage {
    var existingURL: URL? {
        switch self {
        case .url(let url):
            return url
        case .filePath(let fileURL):
            // パス内のUUIDが変わる可能性があるため、ファイルがなければアプリケーションディレクトリを探索する
            // また、tmpディレクトリをそのまま表示させるために、元のファイルの存在チェックをしている
            let fileManager = FileManager.default
            return if fileManager.fileExists(atPath: fileURL.path) {
                fileURL
            } else if let appURL = try? BookImageFileManager().fileURL(fileName: fileURL.lastPathComponent), fileManager.fileExists(atPath: appURL.path) {
                // TODO: ModelでBookImageFileManagerを読んでいるのは依存関係がおかしいので直す
                appURL
            } else {
                nil
            }
        }
    }
}
