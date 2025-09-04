import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAppIntent(),
            phrases: [
                "Open \(.applicationName)"
            ],
            shortTitle: "Open Application",
            systemImageName: "books.vertical.fill"
        )
        AppShortcut(
            intent: AddBookAppIntent(),
            phrases: [
                "Add Book in the \(.applicationName)"
            ],
            shortTitle: "Add Book",
            systemImageName: "books.vertical.fill"
        )
    }
}
