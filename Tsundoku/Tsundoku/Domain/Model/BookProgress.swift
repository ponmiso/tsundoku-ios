protocol BookProgress {
    /// 現在ページ数
    var currentPage: Int? { get }
    /// 最大ページ数
    var maxPage: Int? { get }
}

extension BookProgress {
    var progressText: String {
        if let progress, !isOverPage {
            "\(Int(progress * 100)) %"
        } else {
            "---"
        }
    }

    private var progress: Double? {
        guard let currentPage, let maxPage, maxPage > 0 else {
            return nil
        }
        return Double(currentPage) / Double(maxPage)
    }

    private var isOverPage: Bool {
        guard let currentPage, let maxPage else {
            return false
        }
        return currentPage > maxPage
    }
}
