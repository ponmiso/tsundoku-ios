enum ShortcutItem {
    case add
}

extension ShortcutItem: RawRepresentable {
    typealias RawValue = String?

    init?(rawValue: String?) {
        switch rawValue {
        case "jp.ponmiso.Tsundoku.add":
            self = .add
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
