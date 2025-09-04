enum ShortcutItem: Equatable {
    case add(isbn13: String?)
}

extension ShortcutItem: RawRepresentable {
    typealias RawValue = String?

    init?(rawValue: String?) {
        switch rawValue {
        case "jp.ponmiso.Tsundoku.add":
            self = .add(isbn13: nil)
        default:
            return nil
        }
    }

    var rawValue: String? {
        switch self {
        case .add: return "jp.ponmiso.Tsundoku.add"
        }
    }
}
