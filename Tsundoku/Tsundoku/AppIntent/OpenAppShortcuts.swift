import AppIntents

struct OpenAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAppIntent(),
            phrases: [
                "Open \(.applicationName)"
            ],
            shortTitle: "Open Application",
            systemImageName: "books.vertical.fill"
        )
    }
}
