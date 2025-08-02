import Foundation

struct BookImageFileManager {
    func saveTempPhotosPickerItem(_ imageData: Data) async throws -> URL {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("photo_\(timestamp).jpg")
        try imageData.write(to: tempURL)
        return tempURL
    }

    func moveToFile(from tempURL: URL, for directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = try fileManager.url(
            for: directory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let fileName = tempURL.lastPathComponent
        let destinationURL = documentsURL.appendingPathComponent(fileName)

        // すでに存在していれば削除
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.moveItem(at: tempURL, to: destinationURL)
        return destinationURL
    }
}
