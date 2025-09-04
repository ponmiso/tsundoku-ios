import Foundation

enum GetBookError: Error, LocalizedError {
    case invalidCode(code: String)

    var errorDescription: String? {
        switch self {
        case let .invalidCode(code):
            return "Invalid barcode. Read codes beginning with 978 or 979.\nCodes read: \(code)"
        }
    }
}
