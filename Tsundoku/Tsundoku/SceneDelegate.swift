import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?

    @Published var shortcutItem: ShortcutItem?

    // アプリがショートカットから起動された直後（コールドスタート）
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        window = (scene as? UIWindowScene)?.keyWindow

        if let shortcutItem = connectionOptions.shortcutItem {
            handle(shortcutItem)
        }
    }

    // 既に起動中にクイックアクションが押された（ウォーム）
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = handle(shortcutItem)
        completionHandler(handled)
    }

    @discardableResult
    private func handle(_ item: UIApplicationShortcutItem) -> Bool {
        guard let item = ShortcutItem(rawValue: item.type) else { return false }
        shortcutItem = item
        return true
    }
}
