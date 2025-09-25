import Foundation

struct UserDefaultsManager {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    func save<T>(key: UserDefaultsKey, value: T) where T: Encodable {
        let endodedValue = JSONEncodeManager().encode(value)
        UserDefaults.standard.set(endodedValue, forKey: key.rawValue)
    }

    func load(_ key: UserDefaultsKey) -> Any? {
        guard let endodedValue = UserDefaults.standard.string(forKey: key.rawValue) else {
            return nil
        }
        return JSONEncodeManager().decode(key.valueType, from: endodedValue)
    }
}

extension UserDefaultsManager {
    static let appGroupsSuiteName = "group.jp.ponmiso.Tsundoku"

    static var appGroupsUserDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupsSuiteName)
    }
}

enum UserDefaultsKey: String {
    case unreadBooks

    var valueType: any Decodable.Type {
        switch self {
        case .unreadBooks:
            return [CodableBook].self
        }
    }
}
