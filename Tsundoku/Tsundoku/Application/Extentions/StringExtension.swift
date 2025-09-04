import Foundation

extension String {
    /// value=nil の場合は空文字を返す
    init(_ value: Int?) {
        if let value {
            self = String(value)
        } else {
            self = ""
        }
    }

    var toDateFromYYYYMMDD: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")  // 時間帯やロケールによる影響を排除
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")  // 日本時間を指定

        return formatter.date(from: self)
    }
}
