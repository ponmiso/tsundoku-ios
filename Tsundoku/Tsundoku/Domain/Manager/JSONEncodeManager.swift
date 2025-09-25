import Foundation

struct JSONEncodeManager {
    func encode<T>(_ value: T) -> String where T: Encodable {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value), let json = String(data: data, encoding: .utf8) {
            return json
        } else {
            return ""
        }
    }

    func decode<T>(_ type: T.Type, from json: String) -> T? where T: Decodable {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
