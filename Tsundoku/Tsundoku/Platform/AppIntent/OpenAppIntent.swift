import AppIntents

struct OpenAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Application"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
