import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

struct OpenBDAPI {
    let client: Client

    init() {
        guard let serverURL = try? Servers.Server1.url() else {
            fatalError()
        }
        client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }
}

extension OpenBDAPI {
    func getRepositories(isbn: String) async throws -> OpenBDBookResponse {
        let json = try await client.getBook(query: .init(isbn: isbn)).ok.body.json
        guard let book = json.first else {
            throw OpenBDAPIError.bookNotFound
        }
        return OpenBDBookResponse(book)
    }
}

extension OpenBDAPI {
    // 区切り文字
    static let labelDelimiter = " | "

    enum OpenBDAPIError: Error, LocalizedError {
        case bookNotFound

        var errorDescription: String? {
            switch self {
            case .bookNotFound: return "Book not found"
            }
        }
    }
}
