import Foundation

struct BookImageFileManager {
    func fileURL(fileName: String, for directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = try fileManager.url(
            for: directory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        return destinationURL
    }

    func saveTempPhotosPickerItem(_ imageData: Data) async throws -> URL {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("photo_\(timestamp).jpg")
        try imageData.write(to: tempURL)
        return tempURL
    }

    func moveToFile(from tempURL: URL, for directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) throws -> URL {
        let fileURL = try fileURL(fileName: tempURL.lastPathComponent, for: directory)

        let fileManager = FileManager.default

        // すでに存在していれば削除
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        try fileManager.moveItem(at: tempURL, to: fileURL)
        return fileURL
    }
}
