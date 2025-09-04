import AppIntents

struct AddBookAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Book"
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Enter isbn13. You do not have to enter it.")
    var isbn13: String

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutActionState.shared.shortcutItem = .add(isbn13: isbn13)
        return .result()
    }
}
