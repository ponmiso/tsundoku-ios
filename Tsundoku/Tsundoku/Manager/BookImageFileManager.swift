import Foundation

struct BookImageFileManager {
    func saveTempPhotosPickerItem(_ imageData: Data) async -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("photo_\(timestamp).jpg")
        do {
            try imageData.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
}
