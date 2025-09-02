import AppIntents

struct AddBookAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Book"
    static let openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutActionState.shared.shortcutItem = .add
        return .result()
    }
}
